import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mivo/auth/service/auth_service.dart';
import 'package:mivo/chat/provider/provider.dart';
import 'package:mivo/chat/provider/user_list_provider.dart';
import 'package:mivo/chat/provider/user_profile_provider.dart';
import 'package:mivo/chat/screen/user_list_screen.dart';
import 'package:mivo/auth/screens/user_login_screen.dart';
import 'package:mivo/core/utils/utils.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {

  String? lastUserId;

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final notifier = ref.read(profileProvider.notifier);
    final currentUser = FirebaseAuth.instance.currentUser;

    //check if user has changed and refresh if needed
    if(currentUser?.uid != lastUserId){
      lastUserId = currentUser?.uid;
      // user addPostFrameCallback to aviod calling setState during build
      WidgetsBinding.instance.addPostFrameCallback((_){
        if(mounted){
          notifier.refresh();
        }
      });
    }
    if(profile.isLoading){
      return Scaffold(body: Center(child: CircularProgressIndicator()),);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text('Profile', style: TextStyle(fontWeight: .w600),),
        actions: [IconButton(onPressed: ()=> notifier.refresh(),
            tooltip: "Refresh Profile",
            icon: Icon(Icons.refresh
            ),
        ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Column(
            children: [
              SizedBox(height: 20,),
              Stack(
                alignment: .center,
                children: [
                  CircleAvatar(
                    radius: 60,
                    backgroundImage: (profile.photoUrl != null && profile.photoUrl!.isNotEmpty)
                    ? NetworkImage(profile.photoUrl!)
                        :null,
                    child: (profile.photoUrl == null || profile.photoUrl!.isEmpty)
                    ? const Icon(Icons.person,size: 30,)
                    :null,
                  ),
                  Positioned(
                    bottom: 5,
                    right: 8,
                    child: GestureDetector(
                    onTap: () async {
                      final success = await notifier.updateProfilePicture();
                      if (success && mounted) {
                        showAppSnackbar(
                          context: context,
                          type: SnackbarType.success,
                          description: "Profile picture updated successfully!",
                        );
                      } else if (context.mounted) {
                        showAppSnackbar(
                          context: context,
                          type: SnackbarType.error,
                          description: "Failed to update profile picture.",
                        );
                      }
                    },
                    child: const CircleAvatar(
                      radius: 18,
                      backgroundColor: Colors.black,
                      child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                    ),
                  ),
                  ),
                  if(profile.isUploading)
                    Positioned.fill(child: Center(child: CircularProgressIndicator()),
                    ),
                ],
              ),
              SizedBox(height: 5,),
              Text(profile.name ?? "No Name",
              style: TextStyle(fontSize: 20, fontWeight: .bold),
              ),
              Text(profile.email ?? "No Email",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              //display data
              Text("Joined ${profile.createdAt != null ? DateFormat("MMM d, y").format(profile.createdAt!): "Joined data not available"}",
                style: TextStyle(fontSize: 16, color: Colors.black54),
              ),
              SizedBox(height: 20,),
              MaterialButton(
                color: Colors.blueAccent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  onPressed: ()async{
                    //show confirmation dialog before logging out
                    final shouldLogout = await showDialog<bool>(
                        context: context,
                        builder: (context)=> AlertDialog(
                          backgroundColor: Colors.white,
                          title: const Text("Logout"),
                          content: const Text("Are you sure you want to logout?"),
                          actions: [
                            TextButton(
                                onPressed: ()=> Navigator.pop(context, false),
                                child: const Text("Cancel"),
                            ),
                            TextButton(
                              onPressed: ()=> Navigator.pop(context, true),
                              child: const Text("Logout"),
                            ),
                          ],
                        ),
                    );
                    if(shouldLogout == true){
                      //perform logout
                      await ref.read(authMethodProvider).signOut();
                      //invalidate all providers
                      ref.invalidate(profileProvider);
                      ref.invalidate(userListProvider);
                      ref.invalidate(requestProvider);
                      ref.invalidate(usersProvider);
                      ref.invalidate(filteredUsersProvider);
                      ref.invalidate(searchQueryProvider);
                      ref.invalidate(chatsProvider);

                      if(context.mounted){
                        Navigator.pushAndRemoveUntil(
                          context, 
                          MaterialPageRoute(builder: (context)=> const UserLoginScreen()),
                          (route) => false,
                        );
                      }
                    }
                  },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: .center,
                    children: [
                      Icon(Icons.exit_to_app,color: Colors.white,),
                      SizedBox(width: 5,),
                      Text("Log out",
                      style: TextStyle(color: Colors.white,fontSize: 18, fontWeight: .w600),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
