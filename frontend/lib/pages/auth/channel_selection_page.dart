import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'registration_state.dart';
import 'signup_channel.dart';

enum RegistrationChannel {
  cscCentre,
  communityMobilizer,
  anganwadiCentre,
  ngoPartner,
}

extension RegistrationChannelMapping on RegistrationChannel {
  SignupChannel get asSignupChannel => switch (this) {
        RegistrationChannel.cscCentre => SignupChannel.cscCentre,
        RegistrationChannel.communityMobilizer =>
          SignupChannel.communityMobilizer,
        RegistrationChannel.anganwadiCentre => SignupChannel.anganwadi,
        RegistrationChannel.ngoPartner => SignupChannel.ngoPartner,
      };
}

class ChannelOption {
  const ChannelOption({
    required this.channel,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final RegistrationChannel channel;
  final String title;
  final String subtitle;
  final IconData icon;
}

class ChannelSelectionPage extends ConsumerStatefulWidget {
  const ChannelSelectionPage({super.key});

  @override
  ConsumerState<ChannelSelectionPage> createState() =>
      _ChannelSelectionPageState();
}

class _ChannelSelectionPageState extends ConsumerState<ChannelSelectionPage> {
  RegistrationChannel? _selected;

  static const _gap = 14.0;

  static const List<ChannelOption> _options = [
    ChannelOption(
      channel: RegistrationChannel.cscCentre,
      title: 'CSC Centres',
      subtitle: 'Digital access &\nregistration',
      icon: Icons.apartment_outlined,
    ),
    ChannelOption(
      channel: RegistrationChannel.communityMobilizer,
      title: 'Community Mobilizers',
      subtitle: 'Village verification\n& identification',
      icon: Icons.groups_outlined,
    ),
    ChannelOption(
      channel: RegistrationChannel.anganwadiCentre,
      title: 'Anganwadi Centres',
      subtitle: 'Community access\n& worker outreach',
      icon: Icons.health_and_safety_outlined,
    ),
    ChannelOption(
      channel: RegistrationChannel.ngoPartner,
      title: 'Govt / NGO Partners',
      subtitle: 'Local coordination\n& outreach',
      icon: Icons.account_balance_outlined,
    ),
  ];

  void _onSelect(RegistrationChannel channel) {
    setState(() => _selected = channel);
    ref
        .read(registrationProvider.notifier)
        .setChannel(channel.asSignupChannel);
    // Partner onboarding form for this channel (not worker).
    context.push('/signup/details');
  }

  void _onBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: _onBack,
                  icon: const Icon(Icons.arrow_back),
                  color: const Color(0xFF0D47A1),
                ),
              ),
              const Text(
                'Select registration channel',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              const Text(
                'Choose your sourcing partner type to continue signup',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final cellW = (constraints.maxWidth - _gap) / 2;
                    final maxCellH = (constraints.maxHeight - _gap) / 2;
                    // Between square and full-stretch: solid tiles, not hollow.
                    final cellH = math.min(maxCellH, cellW * 1.2);
                    final gridH = cellH * 2 + _gap;

                    return Align(
                      alignment: const Alignment(0, -0.2),
                      child: SizedBox(
                        width: constraints.maxWidth,
                        height: math.min(gridH, constraints.maxHeight),
                        child: Column(
                          children: [
                            SizedBox(
                              height: cellH,
                              child: Row(
                                children: [
                                  Expanded(child: _channelCard(_options[0])),
                                  const SizedBox(width: _gap),
                                  Expanded(child: _channelCard(_options[1])),
                                ],
                              ),
                            ),
                            const SizedBox(height: _gap),
                            SizedBox(
                              height: cellH,
                              child: Row(
                                children: [
                                  Expanded(child: _channelCard(_options[2])),
                                  const SizedBox(width: _gap),
                                  Expanded(child: _channelCard(_options[3])),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 4, bottom: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF16A34A),
                      size: 18,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Trusted by EarlyJobs Network',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF475569),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _channelCard(ChannelOption item) {
    final isSelected = _selected == item.channel;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFEFF6FF) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSelected
              ? const Color(0xFF0D47A1)
              : const Color(0xFF2563EB).withValues(alpha: 0.4),
          width: isSelected ? 2.0 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: () => _onSelect(item.channel),
          borderRadius: BorderRadius.circular(18),
          splashColor: const Color(0xFF2563EB).withValues(alpha: 0.12),
          highlightColor: const Color(0xFF2563EB).withValues(alpha: 0.06),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  item.icon,
                  size: 36,
                  color: isSelected
                      ? const Color(0xFF0D47A1)
                      : const Color(0xFF2563EB),
                ),
                const SizedBox(height: 10),
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? const Color(0xFF0D47A1)
                        : const Color(0xFF1E293B),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
                const SizedBox(height: 4),
                Text(
                  item.subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF64748B),
                    height: 1.25,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
