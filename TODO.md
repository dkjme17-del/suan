# Fix Provider Error in ProfileScreen

## Plan approved ✓

**Step 1: Create this TODO.md** [COMPLETED]

**Step 2: Edit suan/lib/features/learning/presentation/screens/profile_screen.dart**
- Remove top-level Consumer<RealCommunityService>
- Replace local UserProfile with entity import
- Fix Colors.withValues() → withOpacity()
- Add cloud_firestore import for SetOptions
- Ensure context.read works with Builder if needed

**Step 3: Run flutter analyze & pub get**
```
cd suan
flutter pub get
flutter analyze
```

**Step 4: Hot RESTART app (not reload)** [PENDING]

**Step 5: Test ProfileScreen** [PENDING]
- Navigate to Profile
- Check Friends tab loads
- Add/remove friend
- Edit profile & avatar upload

**Step 6: Update TODO_PROFILE_FIX.md** [Mark complete] [PENDING]

**Step 7: attempt_completion** [PENDING]

