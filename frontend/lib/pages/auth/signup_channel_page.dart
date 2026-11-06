import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/brand.dart';
import 'registration_state.dart';
import 'signup_channel.dart';

class _ChannelOption {
  const _ChannelOption({
    required this.channel,
    required this.title,
    required this.subtitle,
    required this.icon,
  });

  final SignupChannel channel;
  final String title;
  final String subtitle;
  final IconData icon;
}

const _options = <_ChannelOption>[
  _ChannelOption(
    channel: SignupChannel.cscCentre,
    title: 'CSC Centres',
    subtitle: 'Digital access &\nregistration',
    icon: Icons.apartment_outlined,
  ),
  _ChannelOption(
    channel: SignupChannel.communityMobilizer,
    title: 'Community Mobilizers',
    subtitle: 'Village verification\n& identification',
    icon: Icons.groups_outlined,
  ),
  _ChannelOption(
    channel: SignupChannel.anganwadi,
    title: 'Anganwadi Centres',
    subtitle: 'Community access\n& worker outreach',
    icon: Icons.health_and_safety_outlined,
  ),
  _ChannelOption(
    channel: SignupChannel.ngoPartner,
    title: 'Govt / NGO Partners',
    subtitle: 'Local coordination\n& outreach',
    icon: Icons.account_balance_outlined,
  ),
];

void _popOrLogin(BuildContext context) {
  if (context.canPop()) {
    context.pop();
  } else {
    context.go('/login');
  }
}

class SignupChannelPage extends ConsumerStatefulWidget {
  const SignupChannelPage({super.key});

  @override
  ConsumerState<SignupChannelPage> createState() => _SignupChannelPageState();
}

class _SignupChannelPageState extends ConsumerState<SignupChannelPage> {
  SignupChannel? _selected;

  void _onSelect(SignupChannel channel) {
    setState(() => _selected = channel);
    ref.read(registrationProvider.notifier).setChannel(channel);
    context.push('/signup/details');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: BackButton(
          color: const Color(0xFF0D47A1),
          onPressed: () => _popOrLogin(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 12),
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
                'Choose how you are onboarding workers',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Expanded(
                child: GridView.builder(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _options.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.95,
                  ),
                  itemBuilder: (context, index) {
                    final item = _options[index];
                    final isSelected = _selected == item.channel;

                    return GestureDetector(
                      onTap: () => _onSelect(item.channel),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFEFF6FF)
                              : Colors.white,
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
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              item.icon,
                              size: 38,
                              color: isSelected
                                  ? const Color(0xFF0D47A1)
                                  : const Color(0xFF2563EB),
                            ),
                            const SizedBox(height: 12),
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
                                height: 1.2,
                              ),
                              textAlign: TextAlign.center,
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF16A34A),
                      size: 18,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Trusted by ${AppBrand.name} Network',
                      style: const TextStyle(
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
}
