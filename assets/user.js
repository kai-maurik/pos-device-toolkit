// Disable updates & UI nags
user_pref("app.update.enabled", false);
user_pref("app.update.auto", false);
user_pref("browser.aboutConfig.showWarning", false);
user_pref("browser.shell.checkDefaultBrowser", false);

// Disable dialogs & prompts
user_pref("browser.tabs.warnOnClose", false);
user_pref("browser.tabs.warnOnCloseOtherTabs", false);
user_pref("browser.warnOnQuit", false);
user_pref("browser.sessionstore.resume_from_crash", false);

// Disable popups & notifications
user_pref("dom.disable_open_during_load", true);
user_pref("permissions.default.desktop-notification", 2);
user_pref("permissions.default.geo", 2);
user_pref("permissions.default.camera", 2);
user_pref("permissions.default.microphone", 2);

// Disable password / form nags
user_pref("signon.rememberSignons", false);
user_pref("browser.formfill.enable", false);
user_pref("browser.formfill.savePasswords", false);
