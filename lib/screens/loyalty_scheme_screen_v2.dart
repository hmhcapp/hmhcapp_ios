import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

import '../routes.dart';

const _brandOrange = Color(0xFFDD4F2E);
const _brandGold = Color(0xFFF1B227);
const _brandDark = Color(0xFF333333);
const _brandSlate = Color(0xFF595250);
const _brandCream = Color(0xFFF8F4EE);

class LoyaltySchemeScreen extends StatelessWidget {
  const LoyaltySchemeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFFFFF7EC), Color(0xFFF5F1EA)],
          ),
        ),
        child: SafeArea(
          child: user == null || user.isAnonymous
              ? const _GuestState()
              : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  stream: FirebaseFirestore.instance
                      .collection('warranties')
                      .where('userId', isEqualTo: user.uid)
                      .orderBy('timestamp', descending: true)
                      .snapshots(),
                  builder: (context, warrantySnapshot) {
                    if (warrantySnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(color: _brandOrange),
                      );
                    }

                    if (warrantySnapshot.hasError) {
                      return _ErrorState(message: warrantySnapshot.error.toString());
                    }

                    final warrantyDocs = (warrantySnapshot.data?.docs ?? const [])
                        .where((doc) => (doc.data()['deleted'] as bool?) != true)
                        .toList();
                    final entries = warrantyDocs
                        .map((doc) => _LoyaltyEntry.fromMap(doc.data()))
                        .toList();
                    final summary = _LoyaltySummary.fromEntries(entries);

                    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                      stream: FirebaseFirestore.instance
                          .collection('reward_claims')
                          .where('userId', isEqualTo: user.uid)
                          .snapshots(),
                      builder: (context, claimSnapshot) {
                        if (claimSnapshot.connectionState == ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(color: _brandOrange),
                          );
                        }

                        final Map<String, _RewardClaim> claims = {
                          for (final doc in (claimSnapshot.data?.docs ?? const []))
                            doc.id: _RewardClaim.fromMap(doc.id, doc.data()),
                        };

                        return CustomScrollView(
                          slivers: [
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _Header(userEmail: user.email ?? ''),
                                    const SizedBox(height: 20),
                                    _HeroCard(summary: summary),
                                    const SizedBox(height: 20),
                                    _RewardLadder(
                                      summary: summary,
                                      userId: user.uid,
                                      userEmail: user.email ?? '',
                                      claims: claims,
                                    ),
                                    const SizedBox(height: 20),
                                    const _HowPointsWork(),
                                    const SizedBox(height: 20),
                                    _WarrantyBreakdown(entries: summary.entries),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    );
                  },
                ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final String userEmail;

  const _Header({required this.userEmail});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: _brandDark),
          style: IconButton.styleFrom(
            backgroundColor: Colors.white.withOpacity(0.85),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Loyalty Scheme',
                style: GoogleFonts.raleway(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: _brandDark,
                ),
              ),
              if (userEmail.isNotEmpty)
                Text(
                  userEmail,
                  style: GoogleFonts.raleway(
                    color: _brandSlate,
                    fontSize: 13,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  final _LoyaltySummary summary;

  const _HeroCard({required this.summary});

  @override
  Widget build(BuildContext context) {
    final progress = summary.nextLevel == null
        ? 1.0
        : (summary.totalPoints / summary.nextLevel!.target).clamp(0.0, 1.0);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_brandDark, _brandOrange],
        ),
        boxShadow: [
          BoxShadow(
            color: _brandOrange.withOpacity(0.22),
            blurRadius: 20,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(Icons.workspace_premium, color: Colors.white, size: 28),
              ),
              const Spacer(),
              Text(
                '${summary.totalPoints} pts',
                style: GoogleFonts.raleway(
                  fontSize: 30,
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            summary.statusTitle,
            style: GoogleFonts.raleway(
              color: Colors.white,
              fontSize: 21,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            summary.statusSubtitle,
            style: GoogleFonts.raleway(
              color: Colors.white.withOpacity(0.88),
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              minHeight: 12,
              value: progress,
              backgroundColor: Colors.white.withOpacity(0.18),
              valueColor: const AlwaysStoppedAnimation<Color>(_brandGold),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            summary.progressLabel,
            style: GoogleFonts.raleway(
              color: Colors.white.withOpacity(0.9),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _RewardLadder extends StatelessWidget {
  final _LoyaltySummary summary;
  final String userId;
  final String userEmail;
  final Map<String, _RewardClaim> claims;

  const _RewardLadder({
    required this.summary,
    required this.userId,
    required this.userEmail,
    required this.claims,
  });

  @override
  Widget build(BuildContext context) {
    final levels = [
      _RewardLevel(
        key: 'level_1',
        level: 'Level 1',
        target: 25,
        reward: 'Free Cable Safe Monitor',
        color: const Color(0xFFE07A30),
      ),
      _RewardLevel(
        key: 'level_2',
        level: 'Level 2',
        target: 50,
        reward: 'Free Heat Trace Sheet',
        color: const Color(0xFFD95A2E),
      ),
      _RewardLevel(
        key: 'level_3',
        level: 'Level 3',
        target: 100,
        reward: 'Half Price Controller / Thermostat',
        color: const Color(0xFFB23B2B),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reward Levels',
          style: GoogleFonts.raleway(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: _brandDark,
          ),
        ),
        const SizedBox(height: 12),
        ...levels.map((level) {
          final unlocked = summary.totalPoints >= level.target;
          final claimId = _rewardClaimId(userId, level.key);
          final claim = claims[claimId];
          final claimed = claim?.status == 'claimed';

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: claimed ? const Color(0xFFF3F3F3) : Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(
                color: claimed
                    ? Colors.grey.shade400
                    : unlocked
                        ? level.color
                        : Colors.grey.shade300,
                width: unlocked || claimed ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: claimed
                        ? Colors.grey.shade500
                        : unlocked
                            ? level.color
                            : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    claimed
                        ? Icons.verified_rounded
                        : unlocked
                            ? Icons.check
                            : Icons.flag_outlined,
                    color: unlocked || claimed ? Colors.white : Colors.grey.shade600,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${level.level} · ${level.target} pts',
                        style: GoogleFonts.raleway(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: _brandDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        level.reward,
                        style: GoogleFonts.raleway(
                          fontSize: 14,
                          color: _brandSlate,
                          height: 1.35,
                        ),
                      ),
                      if (claimed && claim != null) ...[
                        const SizedBox(height: 6),
                        Text(
                          'Claim code: ${claim.code}',
                          style: GoogleFonts.raleway(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 450),
                  switchInCurve: Curves.easeOutBack,
                  switchOutCurve: Curves.easeIn,
                  child: claimed
                      ? _ClaimedBadge(
                          key: ValueKey('claimed-${level.key}'),
                          claim: claim!,
                        )
                      : unlocked
                          ? _ClaimRewardButton(
                              key: ValueKey('claim-${level.key}'),
                              level: level,
                              userId: userId,
                              userEmail: userEmail,
                              currentPoints: summary.totalPoints,
                            )
                          : const SizedBox.shrink(),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}

class _ClaimRewardButton extends StatefulWidget {
  final _RewardLevel level;
  final String userId;
  final String userEmail;
  final int currentPoints;

  const _ClaimRewardButton({
    super.key,
    required this.level,
    required this.userId,
    required this.userEmail,
    required this.currentPoints,
  });

  @override
  State<_ClaimRewardButton> createState() => _ClaimRewardButtonState();
}

class _ClaimRewardButtonState extends State<_ClaimRewardButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _rotation;
  late final Animation<double> _scale;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _rotation = Tween<double>(begin: -0.02, end: 0.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _scale = Tween<double>(begin: 0.99, end: 1.02).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _claimReward() async {
    if (_submitting) return;

    final code = _generateRewardCode(widget.level);
    final claimId = _rewardClaimId(widget.userId, widget.level.key);
    final db = FirebaseFirestore.instance;

    setState(() => _submitting = true);

    if (!mounted) return;
    _showClaimDialog(
      state: _ClaimDialogState.submitting,
      claimCode: code,
    );

    try {
      await db.collection('reward_claims').doc(claimId).set({
        'id': claimId,
        'userId': widget.userId,
        'userEmail': widget.userEmail,
        'levelKey': widget.level.key,
        'levelLabel': widget.level.level,
        'reward': widget.level.reward,
        'targetPoints': widget.level.target,
        'currentPoints': widget.currentPoints,
        'code': code,
        'status': 'claimed',
        'emailStatus': 'pending',
        'instructions':
            'Write down this reward code and call Heat Mat on 01444 247020 to claim your reward.',
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      setState(() => _submitting = false);
      _showClaimDialog(
        state: _ClaimDialogState.success,
        claimCode: code,
      );
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      setState(() => _submitting = false);
      _showClaimDialog(
        state: _ClaimDialogState.error,
        claimCode: code,
        error: e.toString(),
      );
    }
  }

  Future<void> _showClaimDialog({
    required _ClaimDialogState state,
    required String claimCode,
    String? error,
  }) {
    return showDialog<void>(
      context: context,
      barrierDismissible: state != _ClaimDialogState.submitting,
      builder: (dialogContext) => _ClaimDialog(
        level: widget.level,
        userEmail: widget.userEmail,
        claimCode: claimCode,
        state: state,
        error: error,
        onClose: () => Navigator.of(dialogContext).pop(),
        onCopyCode: () async {
          await Clipboard.setData(ClipboardData(text: claimCode));
          if (!dialogContext.mounted) return;
          ScaffoldMessenger.of(dialogContext).showSnackBar(
            const SnackBar(content: Text('Reward code copied')),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotation.value,
          child: Transform.scale(
            scale: _scale.value,
            child: child,
          ),
        );
      },
      child: ElevatedButton.icon(
        onPressed: _claimReward,
        style: ElevatedButton.styleFrom(
          backgroundColor: widget.level.color,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(999),
          ),
        ),
        icon: _submitting
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.card_giftcard_rounded, size: 16),
        label: Text(
          _submitting ? 'Claiming' : 'Claim',
          style: GoogleFonts.raleway(
            fontWeight: FontWeight.w800,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

class _ClaimDialog extends StatelessWidget {
  final _RewardLevel level;
  final String userEmail;
  final String claimCode;
  final _ClaimDialogState state;
  final String? error;
  final VoidCallback onClose;
  final VoidCallback onCopyCode;

  const _ClaimDialog({
    required this.level,
    required this.userEmail,
    required this.claimCode,
    required this.state,
    required this.onClose,
    required this.onCopyCode,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    final isSuccess = state == _ClaimDialogState.success;
    final isError = state == _ClaimDialogState.error;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      backgroundColor: const Color(0xFFF2F2F2),
      surfaceTintColor: Colors.transparent,
      shadowColor: Colors.black.withOpacity(0.12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2),
          borderRadius: BorderRadius.circular(28),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                switchInCurve: Curves.easeOutBack,
                switchOutCurve: Curves.easeIn,
                child: isSuccess
                    ? Container(
                        key: const ValueKey('success'),
                        width: 72,
                        height: 72,
                        decoration: const BoxDecoration(
                          color: Color(0xFFE1E1E1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check_rounded,
                          size: 42,
                          color: Color(0xFF5F5F5F),
                        ),
                      )
                    : isError
                        ? Container(
                            key: const ValueKey('error'),
                            width: 72,
                            height: 72,
                            decoration: const BoxDecoration(
                              color: Color(0xFFFFECEC),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.error_outline,
                              size: 38,
                              color: Color(0xFFC62828),
                            ),
                          )
                        : const SizedBox(
                            key: ValueKey('loading'),
                            width: 72,
                            height: 72,
                            child: CircularProgressIndicator(
                              strokeWidth: 4,
                              color: _brandOrange,
                            ),
                          ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              isSuccess
                  ? 'Reward Claimed'
                  : isError
                      ? 'Claim Not Completed'
                      : 'Creating Reward Code',
              style: GoogleFonts.raleway(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: _brandDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isSuccess
                  ? 'Write down this reward code and call Heat Mat on 01444 247020 to claim ${level.reward.toLowerCase()}.'
                  : isError
                      ? 'We could not save this claim just yet. You can close this and try again.'
                      : 'Please wait while we generate your unique reward code and save your claim details.',
              style: GoogleFonts.raleway(
                color: _brandSlate,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: const Color(0xFFF2F2F2),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFD9D9D9)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Reward code',
                    style: GoogleFonts.raleway(
                      color: _brandSlate,
                      fontWeight: FontWeight.w700,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    claimCode,
                    style: GoogleFonts.raleway(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: _brandOrange,
                      letterSpacing: 0.8,
                    ),
                  ),
                ],
              ),
            ),
            if (isSuccess) ...[
              const SizedBox(height: 14),
              Text(
                'Check your email. We have sent your reward code to your registered email address. Please keep it safe and call Heat Mat on 01444 247020 to claim your reward.',
                style: GoogleFonts.raleway(
                  color: _brandSlate,
                  fontSize: 13,
                  height: 1.45,
                ),
              ),
            ],
            if (isError && error != null) ...[
              const SizedBox(height: 14),
              Text(
                error!,
                style: GoogleFonts.raleway(
                  color: const Color(0xFFC62828),
                  fontSize: 12,
                  height: 1.35,
                ),
              ),
            ],
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: state == _ClaimDialogState.submitting ? null : onClose,
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      side: const BorderSide(color: _brandOrange),
                      foregroundColor: _brandOrange,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: Text(
                      isSuccess ? 'Done' : 'Close',
                      style: GoogleFonts.raleway(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: state == _ClaimDialogState.submitting ? null : onCopyCode,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size.fromHeight(48),
                      backgroundColor: level.color,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: const Icon(Icons.copy_rounded),
                    label: Text(
                      'Copy Code',
                      style: GoogleFonts.raleway(fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
        ),
      ),
    );
  }
}

class _ClaimedBadge extends StatelessWidget {
  final _RewardClaim claim;

  const _ClaimedBadge({
    super.key,
    required this.claim,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFE7F4EA),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: const Color(0xFF9BC5A4)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, size: 16, color: Color(0xFF2E7D32)),
          const SizedBox(width: 6),
          Text(
            'Claimed',
            style: GoogleFonts.raleway(
              color: const Color(0xFF2E7D32),
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _HowPointsWork extends StatelessWidget {
  const _HowPointsWork();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: _brandCream,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE5D5BF)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'How Points Are Calculated',
            style: GoogleFonts.raleway(
              fontSize: 19,
              fontWeight: FontWeight.w700,
              color: _brandDark,
            ),
          ),
          const SizedBox(height: 12),
          const _RuleTile(
            icon: Icons.grid_view_rounded,
            title: 'PKM, PKC, CBM products',
            body: '5 points per room added on that warranty.',
            color: _brandOrange,
          ),
          const SizedBox(height: 10),
          const _RuleTile(
            icon: Icons.home_work_outlined,
            title: 'HMH products',
            body: '3 points per room added on that warranty.',
            color: _brandGold,
          ),
          const SizedBox(height: 10),
          const _RuleTile(
            icon: Icons.square_foot_outlined,
            title: 'Large floor areas',
            body: '10 extra points for every 25 m2 reached: 25, 50, 75, and so on.',
            color: _brandDark,
          ),
        ],
      ),
    );
  }
}

class _RuleTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String body;
  final Color color;

  const _RuleTile({
    required this.icon,
    required this.title,
    required this.body,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: color.withOpacity(0.12),
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Icon(icon, color: color),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.raleway(
                  fontWeight: FontWeight.w700,
                  color: _brandDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                body,
                style: GoogleFonts.raleway(
                  color: _brandSlate,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _WarrantyBreakdown extends StatelessWidget {
  final List<_LoyaltyEntry> entries;

  const _WarrantyBreakdown({required this.entries});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Warranty Breakdown',
          style: GoogleFonts.raleway(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: _brandDark,
          ),
        ),
        const SizedBox(height: 12),
        if (entries.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
            ),
            child: Text(
              'No saved warranties yet. As soon as you register warranties, your points will appear here.',
              style: GoogleFonts.raleway(
                color: _brandSlate,
                height: 1.45,
              ),
            ),
          )
        else
          ...entries.map(
            (entry) => Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(22),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          entry.productDetails.isEmpty
                              ? 'Warranty ${entry.id}'
                              : entry.productDetails,
                          style: GoogleFonts.raleway(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: _brandDark,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: _brandOrange.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          '+${entry.points} pts',
                          style: GoogleFonts.raleway(
                            color: _brandOrange,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Rooms: ${entry.roomCount} · Floor area: ${entry.floorAreaDisplay}',
                    style: GoogleFonts.raleway(
                      color: _brandSlate,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    entry.explanation,
                    style: GoogleFonts.raleway(
                      color: _brandSlate,
                      height: 1.45,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _GuestState extends StatelessWidget {
  const _GuestState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.workspace_premium, size: 72, color: _brandDark),
            const SizedBox(height: 16),
            Text(
              'Please log in to view your loyalty points.',
              textAlign: TextAlign.center,
              style: GoogleFonts.raleway(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: _brandDark,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pushReplacementNamed(context, Routes.login),
              style: ElevatedButton.styleFrom(backgroundColor: _brandOrange),
              child: Text(
                'Login / Register',
                style: GoogleFonts.raleway(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;

  const _ErrorState({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text(
          'Could not load loyalty points.\n$message',
          textAlign: TextAlign.center,
          style: GoogleFonts.raleway(color: _brandDark),
        ),
      ),
    );
  }
}

class _RewardLevel {
  final String key;
  final String level;
  final int target;
  final String reward;
  final Color color;

  const _RewardLevel({
    required this.key,
    required this.level,
    required this.target,
    required this.reward,
    required this.color,
  });
}

class _LoyaltySummary {
  final int totalPoints;
  final List<_LoyaltyEntry> entries;
  final _RewardMilestone? nextLevel;

  const _LoyaltySummary({
    required this.totalPoints,
    required this.entries,
    required this.nextLevel,
  });

  factory _LoyaltySummary.fromEntries(List<_LoyaltyEntry> entries) {
    final total = entries.fold<int>(0, (sum, entry) => sum + entry.points);
    const milestones = [
      _RewardMilestone(25, 'Free Cable Safe Monitor'),
      _RewardMilestone(50, 'Free Heat Trace Sheet'),
      _RewardMilestone(100, 'Half Price Controller / Thermostat'),
    ];

    _RewardMilestone? next;
    for (final milestone in milestones) {
      if (total < milestone.target) {
        next = milestone;
        break;
      }
    }

    return _LoyaltySummary(
      totalPoints: total,
      entries: entries,
      nextLevel: next,
    );
  }

  String get statusTitle {
    if (totalPoints >= 100) return 'Level 3 reached';
    if (totalPoints >= 50) return 'Level 2 reached';
    if (totalPoints >= 25) return 'Level 1 reached';
    return 'Building your reward balance';
  }

  String get statusSubtitle {
    if (nextLevel == null) {
      return 'You have unlocked every current reward tier in the scheme.';
    }
    return '${nextLevel!.target - totalPoints} more points until ${nextLevel!.reward}.';
  }

  String get progressLabel {
    if (nextLevel == null) return 'All current levels unlocked';
    return '$totalPoints / ${nextLevel!.target} points towards ${nextLevel!.reward}';
  }
}

class _RewardMilestone {
  final int target;
  final String reward;

  const _RewardMilestone(this.target, this.reward);
}

class _LoyaltyEntry {
  final String id;
  final String productDetails;
  final int roomCount;
  final double? floorArea;
  final int points;
  final String explanation;

  const _LoyaltyEntry({
    required this.id,
    required this.productDetails,
    required this.roomCount,
    required this.floorArea,
    required this.points,
    required this.explanation,
  });

  factory _LoyaltyEntry.fromMap(Map<String, dynamic> data) {
    final id = (data['id'] ?? '').toString();
    final productDetails = (data['productDetails'] ?? '').toString().trim();
    final roomTypes = (data['roomTypes'] as List?)
            ?.map((item) => item.toString().trim())
            .where((item) => item.isNotEmpty)
            .toList() ??
        const <String>[];
    final roomCount = roomTypes.length;
    final floorArea = _parseFloorArea((data['floorArea'] ?? '').toString());

    final prefix = productDetails.toUpperCase();
    final pointsPerRoom = (prefix.startsWith('PKM') ||
            prefix.startsWith('PKC') ||
            prefix.startsWith('CBM'))
        ? 5
        : prefix.startsWith('HMH')
            ? 3
            : 0;
    final roomPoints = roomCount * pointsPerRoom;
    final areaBonus = floorArea == null ? 0 : (floorArea ~/ 25) * 10;
    final totalPoints = roomPoints + areaBonus;

    final explainer = <String>[];
    if (roomPoints > 0) {
      explainer.add('$roomCount room${roomCount == 1 ? '' : 's'} x $pointsPerRoom pts');
    }
    if (areaBonus > 0 && floorArea != null) {
      explainer.add(
        '${floorArea.toStringAsFixed(floorArea % 1 == 0 ? 0 : 1)} m2 area bonus: +$areaBonus pts',
      );
    }
    if (explainer.isEmpty) {
      explainer.add('No loyalty points matched this warranty yet.');
    }

    return _LoyaltyEntry(
      id: id,
      productDetails: productDetails,
      roomCount: roomCount,
      floorArea: floorArea,
      points: totalPoints,
      explanation: explainer.join(' · '),
    );
  }

  String get floorAreaDisplay {
    if (floorArea == null) return 'Not provided';
    return floorArea! % 1 == 0
        ? '${floorArea!.toStringAsFixed(0)} m2'
        : '${floorArea!.toStringAsFixed(1)} m2';
  }

  static double? _parseFloorArea(String value) {
    final match = RegExp(r'(\d+(?:\.\d+)?)').firstMatch(value.replaceAll(',', '.'));
    if (match == null) return null;
    return double.tryParse(match.group(1)!);
  }
}

class _RewardClaim {
  final String id;
  final String levelKey;
  final String code;
  final String status;
  final String reward;
  final String userEmail;

  const _RewardClaim({
    required this.id,
    required this.levelKey,
    required this.code,
    required this.status,
    required this.reward,
    required this.userEmail,
  });

  factory _RewardClaim.fromMap(String id, Map<String, dynamic> data) {
    return _RewardClaim(
      id: id,
      levelKey: (data['levelKey'] ?? '').toString(),
      code: (data['code'] ?? '').toString(),
      status: (data['status'] ?? '').toString(),
      reward: (data['reward'] ?? '').toString(),
      userEmail: (data['userEmail'] ?? '').toString(),
    );
  }
}

enum _ClaimDialogState { submitting, success, error }

String _rewardClaimId(String userId, String levelKey) => '${userId}_$levelKey';

String _generateRewardCode(_RewardLevel level) {
  final now = DateTime.now().millisecondsSinceEpoch;
  final suffix = (now % 100000).toString().padLeft(5, '0');
  return 'HM-${level.key.toUpperCase()}-$suffix';
}
