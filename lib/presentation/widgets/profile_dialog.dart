import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_page_controller.dart';
import '../../utils/cloud_storage_service.dart';

class ProfileDialog extends StatefulWidget {
  const ProfileDialog({super.key});

  @override
  State<ProfileDialog> createState() => _ProfileDialogState();
}

class _ProfileDialogState extends State<ProfileDialog> {
  final HomePageController controller = Get.find<HomePageController>();

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fileNameController = TextEditingController();

  bool _isSignUp = false;
  bool _isLoading = false;
  String _authError = "";

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fileNameController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime dt) {
    final y = dt.year;
    final m = dt.month.toString().padLeft(2, '0');
    final d = dt.day.toString().padLeft(2, '0');
    final hr = dt.hour.toString().padLeft(2, '0');
    final min = dt.minute.toString().padLeft(2, '0');
    return "$y-$m-$d $hr:$min";
  }

  String _formatSize(int bytes) {
    if (bytes < 1024) return "$bytes B";
    final kb = bytes / 1024.0;
    if (kb < 1024) return "${kb.toStringAsFixed(1)} KB";
    final mb = kb / 1024.0;
    return "${mb.toStringAsFixed(1)} MB";
  }

  void _submitAuth() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      setState(() => _authError = "Please fill in all fields");
      return;
    }
    if (password.length < 6) {
      setState(() => _authError = "Password must be at least 6 characters");
      return;
    }

    setState(() {
      _isLoading = true;
      _authError = "";
    });

    bool success;
    if (_isSignUp) {
      success = await controller.signUpCloud(email, password);
    } else {
      success = await controller.loginCloud(email, password);
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
      if (success) {
        _emailController.clear();
        _passwordController.clear();
      } else {
        setState(() {
          _authError = _isSignUp
              ? "Authentication failed. Try another email."
              : "Login failed. Check your email and password.";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isDark = controller.isDark.value == 1;
      final email = controller.currentUserEmail.value;
      final savedList = controller.savedJsons;
      final syncMode = controller.cloudSyncMode.value;

      final cardColor = isDark ? const Color(0xFF161B22) : Colors.white;
      final textColor = isDark ? const Color(0xFFE6EDF3) : const Color(0xFF24292F);
      final subtitleColor = isDark ? const Color(0xFF8B949E) : Colors.black54;
      final borderColor = isDark ? const Color(0xFF30363D) : const Color(0xFFD0D7DE);

      return Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          width: 440,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: borderColor),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: AnimatedSize(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            child: email == null
                ? _buildAuthView(textColor, subtitleColor, isDark, syncMode)
                : _buildDashboardView(textColor, subtitleColor, isDark, email, savedList, syncMode, borderColor),
          ),
        ),
      );
    });
  }

  Widget _buildAuthView(Color textColor, Color subtitleColor, bool isDark, String syncMode) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _isSignUp ? "Create Account" : "Cloud Account",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: textColor),
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Get.back(),
              color: subtitleColor,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          "Access cloud saves, backups, and format settings from anywhere.",
          style: TextStyle(fontSize: 13, color: subtitleColor),
        ),
        const SizedBox(height: 16),

        // Sync Mode Selector
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF0D1117) : const Color(0xFFF6F8FA),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: isDark ? const Color(0xFF30363D) : const Color(0xFFD0D7DE)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Sync Destination:",
                style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor),
              ),
              DropdownButton<String>(
                value: syncMode,
                underline: const SizedBox(),
                dropdownColor: isDark ? const Color(0xFF161B22) : Colors.white,
                style: TextStyle(fontSize: 12, color: textColor, fontWeight: FontWeight.w600),
                onChanged: (val) {
                  if (val != null) controller.toggleCloudMode(val);
                },
                items: [
                  const DropdownMenuItem(
                    value: 'Local',
                    child: Text("Simulated Sync (Local)"),
                  ),
                  DropdownMenuItem(
                    value: 'Firebase',
                    child: Text(
                      "Firebase Firestore",
                      style: TextStyle(
                        color: CloudStorageManager.firebaseInitialized
                            ? null
                            : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Email field
        TextField(
          controller: _emailController,
          decoration: InputDecoration(
            labelText: "Email",
            labelStyle: TextStyle(color: subtitleColor),
            prefixIcon: Icon(Icons.email_outlined, color: subtitleColor),
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          ),
          style: TextStyle(color: textColor, fontSize: 14),
        ),
        const SizedBox(height: 12),

        // Password field
        TextField(
          controller: _passwordController,
          obscureText: true,
          decoration: InputDecoration(
            labelText: "Password (min 6 chars)",
            labelStyle: TextStyle(color: subtitleColor),
            prefixIcon: Icon(Icons.lock_outline_rounded, color: subtitleColor),
            border: const OutlineInputBorder(),
            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
          ),
          style: TextStyle(color: textColor, fontSize: 14),
          onSubmitted: (_) => _submitAuth(),
        ),

        if (_authError.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(
            _authError,
            style: const TextStyle(color: Colors.redAccent, fontSize: 12),
          ),
        ],

        const SizedBox(height: 16),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.indigoAccent,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 12),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: _isLoading ? null : _submitAuth,
          child: _isLoading
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                )
              : Text(_isSignUp ? "Sign Up" : "Log In"),
        ),
        const SizedBox(height: 12),
        Center(
          child: TextButton(
            onPressed: () {
              setState(() {
                _isSignUp = !_isSignUp;
                _authError = "";
              });
            },
            child: Text(
              _isSignUp ? "Already have an account? Log In" : "Don't have an account? Sign Up",
              style: const TextStyle(color: Colors.indigoAccent, fontSize: 12),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDashboardView(
    Color textColor,
    Color subtitleColor,
    bool isDark,
    String email,
    List savedList,
    String syncMode,
    Color borderColor,
  ) {
    final int count = savedList.length;
    final double usagePct = count / 5.0;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.indigoAccent.withOpacity(0.2),
                  child: const Icon(Icons.person, color: Colors.indigoAccent),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      email,
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: textColor),
                    ),
                    Text(
                      "Sync: $syncMode",
                      style: TextStyle(fontSize: 11, color: subtitleColor),
                    ),
                  ],
                ),
              ],
            ),
            IconButton(
              icon: const Icon(Icons.close),
              onPressed: () => Get.back(),
              color: subtitleColor,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Storage limits indicator
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Cloud Storage Space",
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: textColor),
                ),
                Text(
                  "$count / 5 slots used",
                  style: TextStyle(fontSize: 12, color: subtitleColor, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: usagePct,
                backgroundColor: isDark ? const Color(0xFF30363D) : const Color(0xFFE2E8F0),
                valueColor: AlwaysStoppedAnimation<Color>(
                  count >= 5 ? Colors.redAccent : Colors.indigoAccent,
                ),
                minHeight: 8,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Save Current JSON Row
        Text(
          "Save Current Editor JSON",
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: TextField(
                controller: _fileNameController,
                decoration: InputDecoration(
                  hintText: "Document name (e.g. config)",
                  hintStyle: TextStyle(color: subtitleColor, fontSize: 13),
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                ),
                style: TextStyle(color: textColor, fontSize: 13),
              ),
            ),
            const SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigoAccent,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
              onPressed: () async {
                final name = _fileNameController.text.trim();
                if (name.isEmpty) {
                  Get.snackbar("Error", "Please enter a name");
                  return;
                }
                final success = await controller.saveCurrentJsonToCloud(name);
                if (success) {
                  _fileNameController.clear();
                  setState(() {});
                }
              },
              child: const Text("Save", style: TextStyle(fontSize: 13)),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Saved list
        Text(
          "Saved Cloud Documents",
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor),
        ),
        const SizedBox(height: 8),
        if (count == 0)
          Container(
            padding: const EdgeInsets.symmetric(vertical: 24),
            alignment: Alignment.center,
            child: Text(
              "No saved cloud documents found.",
              style: TextStyle(color: subtitleColor, fontSize: 12, fontStyle: FontStyle.italic),
            ),
          )
        else
          Container(
            constraints: const BoxConstraints(maxHeight: 180),
            decoration: BoxDecoration(
              border: Border.all(color: borderColor),
              borderRadius: BorderRadius.circular(8),
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: count,
              separatorBuilder: (_, __) => Divider(height: 1, color: borderColor),
              itemBuilder: (context, index) {
                final item = savedList[index];
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              item.name,
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: textColor),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "${_formatSize(item.size)} • ${_formatDate(item.updatedAt)}",
                              style: TextStyle(fontSize: 11, color: subtitleColor),
                            ),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.indigoAccent,
                              padding: const EdgeInsets.symmetric(horizontal: 10),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            onPressed: () => controller.loadCloudJson(item.content),
                            child: const Text("Load", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                          ),
                          const SizedBox(width: 4),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, size: 18),
                            color: Colors.redAccent,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(),
                            onPressed: () => controller.deleteJsonFromCloud(item.id),
                            tooltip: "Delete",
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),

        const SizedBox(height: 24),
        OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.redAccent,
            side: const BorderSide(color: Colors.redAccent),
            padding: const EdgeInsets.symmetric(vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          onPressed: () {
            controller.logoutCloud();
          },
          icon: const Icon(Icons.logout_rounded, size: 16),
          label: const Text("Log Out Account", style: TextStyle(fontSize: 13)),
        ),
      ],
    );
  }
}
