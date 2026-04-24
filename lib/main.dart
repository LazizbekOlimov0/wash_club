import 'app.dart';

void main() => run();


/// ------------------------------------------ Flutter Commands -------------------------------------------
/// flutter build apk --release
/// flutter build apk --split-per-abi
/// flutter build appbundle --release
/// flutter build ios --release
/// flutter pub run build_runner build --delete-conflicting-outputs
/// flutter pub ipa
/// flutter gen-l10n
/// dart run build_runner clean
/// dart run slang

/// ------------------------------------------ Git Commands -----------------------------------------------
/// git add . - Stages all changes
/// git commit -m "Your message" - Commits staged changes with a message
/// git push - Pushes commits to remote repository
/// git pull - Fetches and merges changes from remote repository
/// git status - Shows the status of working directory and staging area
/// --- Branch Commands ---
/// git branch <branch-name> - Creates a new branch
/// git checkout -b <branch-name> - Creates and switches to new branch (shortcut)
/// git switch -c <branch-name> - Creates and switches to new branch (modern way)
/// git branch - Lists all local branches
/// git checkout <branch-name> - Switches to existing branch
/// git switch <branch-name> - Switches to existing branch (modern way)
/// git branch -d <branch-name> - Deletes a branch (safe)
/// git branch -D <branch-name> - Force deletes a branch

/// ------------------------------------ Shorebird Configuration ------------------------------------------
/// shorebird release ios
/// shorebird release android
/// shorebird patch android
/// shorebird patch ios
/// shorebird release android --artifact=apk
/// shorebird preview
/// shorebird patch --platforms=ios --release-version=1.1.3+45


/// rm -rf Pods Podfile.lock
/// pod deintegrate
/// pod install