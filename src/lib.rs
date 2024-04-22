use std::fs;
use zed::settings::{self, BinarySettings, LspSettings};
use zed_extension_api::{self as zed, serde_json, Result};

// This code was adapted from the csharp extension that is built into Zed.
// That code carried an Apache 2.0 license.

struct DExtension {
    cached_binary_path: Option<String>,
}

impl DExtension {
    fn language_server_binary_path(
        &mut self,
        language_server_id: &zed::LanguageServerId,
        worktree: &zed::Worktree,
    ) -> Result<String> {
        if let Some(path) = &self.cached_binary_path {
            if fs::metadata(path).map_or(false, |stat| stat.is_file()) {
                return Ok(path.clone());
            }
        }

        if let Some(path) = worktree.which("serve-d") {
            self.cached_binary_path = Some(path.clone());
            return Ok(path);
        }

        zed::set_language_server_installation_status(
            &language_server_id,
            &zed::LanguageServerInstallationStatus::CheckingForUpdate,
        );
        let release = zed::latest_github_release(
            "Pure-D/serve-d",
            zed::GithubReleaseOptions {
                require_assets: true,
                pre_release: true, // TODO: serve-d "release" builds are too ancient to be useful
            },
        )?;

        fn trim_first(value: &str) -> &str {
            let mut chars = value.chars();
            chars.next();
            chars.as_str()
        }

        let (platform, arch) = zed::current_platform();
        let asset_name = format!(
            "serve-d_{version}-{os}-{arch}{extension}",
            os = match platform {
                zed::Os::Mac => "osx",
                zed::Os::Linux => "linux",
                zed::Os::Windows => "windows",
            },
            arch = match arch {
                // NB: no 32-bit support
                zed::Architecture::Aarch64 => "arm64",
                zed::Architecture::X8664 => "x86_64",
                zed::Architecture::X86 => "x86",
            },
            extension = match platform {
                zed::Os::Mac => ".tar.gz",
                zed::Os::Linux => ".tar.gz",
                zed::Os::Windows => ".zip",
            },
            version = trim_first(release.version.as_str())
        );

        let asset = release
            .assets
            .iter()
            .find(|asset| asset.name == asset_name)
            .ok_or_else(|| format!("no asset found matching {:?}", asset_name))?;

        let version_dir = format!("serve-d-{}", release.version);
        let binary_path = format!("{version_dir}/serve-d");

        if !fs::metadata(&binary_path).map_or(false, |stat| stat.is_file()) {
            zed::set_language_server_installation_status(
                &language_server_id,
                &zed::LanguageServerInstallationStatus::Downloading,
            );
        }

        zed::download_file(
            &asset.download_url,
            &version_dir,
            match platform {
                zed::Os::Mac | zed::Os::Linux => zed::DownloadedFileType::GzipTar,
                zed::Os::Windows => zed::DownloadedFileType::Zip,
            },
        )
        .map_err(|e| format!("failed to dowload file: {e}"))?;

        let entries =
            fs::read_dir(".").map_err(|e| format!("failed to list working directory {e}"))?;
        for entry in entries {
            let entry = entry.map_err(|e| format!("failed to load directory entry {e}"))?;
            if entry.file_name().to_str() != Some(&version_dir) {
                fs::remove_dir_all(&entry.path()).ok();
            }
        }

        self.cached_binary_path = Some(binary_path.clone());
        Ok(binary_path)
    }
}

impl zed::Extension for DExtension {
    fn new() -> Self {
        Self {
            cached_binary_path: None,
        }
    }

    fn language_server_command(
        &mut self,
        language_server_id: &zed::LanguageServerId,
        worktree: &zed::Worktree,
    ) -> Result<zed::Command> {
        Ok(zed::Command {
            command: self.language_server_binary_path(language_server_id, worktree)?,
            args: vec![
                "--provide".to_string(),
                "contexts-snippets".to_string(),
                "--provide".to_string(),
                "default-snippets".to_string(),
                "--loglevel".to_string(),
                "trace".to_string(),
                "--logfile".to_string(),
                "/var/tmp/served.log".to_string(),
            ],
            env: Default::default(),
        })
    }

    // fn language_server_workspace_configuration(
    //     &mut self,
    //     _language_server_id: &zed::LanguageServerId,
    //     _worktree: &zed::Worktree,
    // ) -> Result<Option<serde_json::Value>> {
    //     Ok(Some(serde_json::json!(LspSettings::for_worktree(
    //         "serve-d", _worktree
    //     ))))
    // }

    fn language_server_workspace_configuration(
        &mut self,
        _language_server_id: &zed::LanguageServerId,
        _worktree: &zed::Worktree,
    ) -> Result<Option<serde_json::Value>> {
        let serde_d_settings = LspSettings::for_worktree("serve-d", _worktree).ok();

        let settings = LspSettings::for_worktree("serve-d", _worktree)
            .ok()
            .and_then(|lsp_settings| lsp_settings.settings.clone())
            .unwrap_or_default();

        std::fs::write(
            "all_lsp_settings.json",
            serde_json::to_string_pretty(&serde_d_settings).unwrap(),
        )
        .unwrap();

        // ~/Library/Application\ Support/Zed/extensions/work/d/
        std::fs::write(
            "lsp_settings.json",
            serde_json::to_string_pretty(&settings).unwrap(),
        )
        .unwrap();

        println!("{settings:?}");
        Ok(Some(serde_json::json!(settings)))
    }
}
zed::register_extension!(DExtension);
