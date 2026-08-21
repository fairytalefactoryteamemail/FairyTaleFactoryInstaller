enum InstallerMode { install, update, repair }

class InstallerManifest {
  final String appId;
  final String appName;
  final String publisher;
  final String version;
  final String mainExeName;
  final String defaultInstallSubDir; // مثلاً 'Taleforger'
  final int estimatedSizeKB;

  InstallerManifest({
    required this.appId,
    required this.appName,
    required this.publisher,
    required this.version,
    required this.mainExeName,
    required this.defaultInstallSubDir,
    required this.estimatedSizeKB,
  });

  factory InstallerManifest.fromJson(Map<String, dynamic> json) {
    return InstallerManifest(
      appId: json['appId'] ?? 'App_Id',
      appName: json['appName'] ?? 'My Application',
      publisher: json['publisher'] ?? 'Developer',
      version: json['version'] ?? '1.0.0',
      mainExeName: json['mainExeName'] ?? 'app.exe',
      defaultInstallSubDir: json['defaultInstallSubDir'] ?? 'MyApp',
      estimatedSizeKB: json['estimatedSizeKB'] ?? 50000,
    );
  }
}