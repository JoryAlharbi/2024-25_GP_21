
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:google_fonts/google_fonts.dart';

class TutorialService {
  static const String _tutorialKey = 'tutorial_completed';
  static const String _writingTutorialKey = 'writing_tutorial_completed';
  static bool _tutorialActive = false;
  static int _currentStep = 0;
  
  // Check if the user has completed the main tutorial
  static Future<bool> isTutorialCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_tutorialKey) ?? false;
  }
  
  // Check if the user has completed the writing tutorial
  static Future<bool> isWritingTutorialCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_writingTutorialKey) ?? false;
  }
  
  // Mark the main tutorial as completed
  static Future<void> markTutorialCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_tutorialKey, true);
    _tutorialActive = false;
  }
  
  // Mark the writing tutorial as completed
  static Future<void> markWritingTutorialCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_writingTutorialKey, true);
    
  }
  
  // Reset the tutorial state
  static void resetTutorial() {
    _currentStep = 0;
    _tutorialActive = false;
  }
  
  // Get the current tutorial state
  static bool get isActive => _tutorialActive;
  static int get currentStep => _currentStep;
  
  // Start the tutorial on the HomePage
  static Future<void> startHomeTutorial(BuildContext context, GlobalKey fabKey) async {
    // final completed = await isTutorialCompleted();
    
    // if (completed) return;
    // -----------------------------For testing purposes,_______-----------------------
    
    
    _tutorialActive = true;
    _currentStep = 0;
    
    // Create target for the floating action button
    final targets = [
      TargetFocus(
        identify: "fab_button",
        keyTarget: fabKey,
        alignSkip: Alignment.bottomLeft,
        enableOverlayTab: false,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Container(
                padding: const EdgeInsets.only(bottom: 100),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      "Create Your Story",
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Tap this orange button to start writing your own story thread",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    const Icon(
                      Icons.arrow_downward,
                      color: Colors.white,
                      size: 32,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    ];
    
    Future.delayed(const Duration(milliseconds: 300), () {
      TutorialCoachMark(
        targets: targets,
        colorShadow: const Color(0xFFD35400).withOpacity(0.9),
        hideSkip: false,
        textSkip: "SKIP TUTORIAL",
        paddingFocus: 10,
        opacityShadow: 0.8,
        onFinish: () {
          // Don't mark as completed yet, just move to the next step
          _currentStep = 1;
        },
        onSkip: () {
          // User skipped the tutorial
          markTutorialCompleted();
          return false;
        }
      ).show(context: context);
    });
  }
  
  // Continue the tutorial on the MakeThreadPage
  static void continueThreadTutorial(
    BuildContext context, {
    required GlobalKey titleKey,
    required GlobalKey genreKey,
    required GlobalKey coverKey,
    required GlobalKey createButtonKey,
  }) {
    if (!_tutorialActive || _currentStep != 1) return;
    
    _currentStep = 2;
    
    final targets = [
      TargetFocus(
        identify: "title_field",
        keyTarget: titleKey,
        alignSkip: Alignment.bottomLeft,
        shape: ShapeLightFocus.RRect,
        radius: 10,
        paddingFocus: 5,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Container(
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(maxWidth: 250),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Enter Your Book Title",
                      style: GoogleFonts.poppins(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Give your story a catchy and meaningful title",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "genre_selection",
        keyTarget: genreKey,
        alignSkip: Alignment.bottomLeft,
        shape: ShapeLightFocus.RRect,
        radius: 10,
        paddingFocus: 5,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Select Genre(s)",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Choose one or more genres that best fit your story",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "book_cover",
        keyTarget: coverKey,
        alignSkip: Alignment.bottomLeft,
        shape: ShapeLightFocus.RRect,
        radius: 10,
        paddingFocus: 5,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Choose a Book Cover",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Upload your own cover or generate one",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "create_button",
        keyTarget: createButtonKey,
        alignSkip: Alignment.bottomLeft,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Container(
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Create Your Thread",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "When you're ready, tap the Create button to start your story",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    ];

    TutorialCoachMark(
      targets: targets,
      colorShadow: const Color(0xFFD35400).withOpacity(0.9),
      hideSkip: false,
      textSkip: "SKIP TUTORIAL",
      paddingFocus: 10,
      opacityShadow: 0.8,
      onFinish: () {
        // Mark tutorial as completed when finished on the MakeThreadPage
        markTutorialCompleted();
      },
      onSkip: () {
        // User skipped the tutorial
        markTutorialCompleted();
        return false;
      }
    ).show(context: context);
  }
  
  // Start the tutorial on the WritingPage
  static void startWritingTutorial(
    BuildContext context, {

    required GlobalKey textFieldKey,
    required GlobalKey ideaButtonKey,
    required GlobalKey doneButtonKey,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final tutorialCompleted = prefs.getBool(_writingTutorialKey) ?? false;
    
    if (tutorialCompleted) return;
    
    final targets = [
      // TargetFocus(
      //   identify: "profile_section",
      //   keyTarget: profileKey,
      //   alignSkip: Alignment.bottomRight,
      //   enableOverlayTab: false,
      //   shape: ShapeLightFocus.RRect,
      //   radius: 10,
      //   contents: [
      //     TargetContent(
      //       align: ContentAlign.bottom,
      //       builder: (context, controller) {
      //         return Container(
      //           padding: const EdgeInsets.all(16),
      //           child: Column(
      //             mainAxisSize: MainAxisSize.min,
      //             children: [
      //               Text(
      //                 "Your Profile",
      //                 style: GoogleFonts.poppins(
      //                   fontSize: 20,
      //                   fontWeight: FontWeight.bold,
      //                   color: Colors.white,
      //                 ),
      //               ),
      //               const SizedBox(height: 8),
      //               Text(
      //                 "This shows your profile as the author of this part of the story",
      //                 style: GoogleFonts.poppins(
      //                   fontSize: 16,
      //                   color: Colors.white,
      //                 ),
      //                 textAlign: TextAlign.center,
      //               ),
      //             ],
      //           ),
      //         );
      //       },
      //     ),
      //   ],
      // ),
      TargetFocus(
        identify: "writing_area",
        keyTarget: textFieldKey,
        alignSkip: Alignment.bottomRight,
        enableOverlayTab: false,
        shape: ShapeLightFocus.RRect,
        radius: 10,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Container(
                padding: const EdgeInsets.all(16),
                constraints: const BoxConstraints(maxWidth: 300),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Write Your Story",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "This is where you write your contribution to the story. Be creative and continue the narrative!",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "idea_button",
        keyTarget: ideaButtonKey,
        alignSkip: Alignment.bottomRight,
        enableOverlayTab: false,
        shape: ShapeLightFocus.Circle,
        contents: [
          TargetContent(
            align: ContentAlign.top,
            builder: (context, controller) {
              return Container(
                padding: const EdgeInsets.all(16),
                constraints: const BoxConstraints(maxWidth: 300),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Need Ideas?",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "Tap this magical wand for writing suggestions if you're feeling stuck",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      TargetFocus(
        identify: "done_button",
        keyTarget: doneButtonKey,
        alignSkip: Alignment.bottomRight,
        enableOverlayTab: false,
        shape: ShapeLightFocus.RRect,
        radius: 10,
        contents: [
          TargetContent(
            align: ContentAlign.bottom,
            builder: (context, controller) {
              return Container(
                padding: const EdgeInsets.all(16),
                constraints: const BoxConstraints(maxWidth: 300),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      "Submit Your Part",
                      style: GoogleFonts.poppins(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "When you're satisfied with your story contribution, tap Done to submit it",
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      "After submitting, you'll be able to create characters from your story",
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontStyle: FontStyle.italic,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    ];
    
    Future.delayed(const Duration(milliseconds: 500), () {
      TutorialCoachMark(
        targets: targets,
        colorShadow: const Color(0xFFD35400).withOpacity(0.9),
        hideSkip: false,
        textSkip: "SKIP TUTORIAL",
        paddingFocus: 10,
        opacityShadow: 0.8,
        onFinish: () {
          markWritingTutorialCompleted();
        },
        onSkip: () {
          markWritingTutorialCompleted();
          return false;
        }
      ).show(context: context);
    });
  }
}