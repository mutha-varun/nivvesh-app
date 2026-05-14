/// First-party URLs shown inside in-app WebViews (login help, home FD entry).
///
/// Adjust [nivveshPublicWebOrigin] and paths when your production marketing
/// and help pages are live.
const nivveshPublicWebOrigin = 'https://nivvesh.com';

/// Login screen help (see `SupportWebView` from `login_page.dart`).
const nivveshSupportWebUrl = '$nivveshPublicWebOrigin/support';

/// Home FAB “FDs” / `GoRoute` `/bank` (`InAppWebViewScreen`).
const nivveshFdsWebUrl = '$nivveshPublicWebOrigin/fds';
