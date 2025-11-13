import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
	final int currentIndex;
	final ValueChanged<int>? onTap;
	final double height;
	final double barHeight;
	final double centerButtonDiameter;

	const BottomNavBar({
		Key? key,
		this.currentIndex = 0,
		this.onTap,
		this.height = 80,
		this.barHeight = 60,
		this.centerButtonDiameter = 64,
	}) : super(key: key);

	@override
	Widget build(BuildContext context) {
		final Color activeColor = const Color.fromARGB(255, 255, 191, 0);
		final Color inactiveColor = const Color.fromARGB(255, 0, 0, 0);

			final double gapForCenter = centerButtonDiameter - 8; // spacer width under center button

			return SizedBox(
				height: height,
			child: Stack(
				alignment: Alignment.topCenter,
				children: [
								Positioned(
									bottom: 0,
									left: 0,
									right: 0,
									child: Container(
										height: barHeight,
							decoration: BoxDecoration(
								color: const Color.fromARGB(255, 236, 223, 223),
								boxShadow: [
									BoxShadow(color: Colors.black12.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, -2)),
								],
							),
							child: Row(
								mainAxisAlignment: MainAxisAlignment.spaceAround,
								children: [
									_NavButton(
										icon: Icons.layers,
										index: 0,
										isActive: currentIndex == 0,
										activeColor: activeColor,
										inactiveColor: inactiveColor,
										onTap: onTap,
									),
									_NavButton(
										icon: Icons.search,
										index: 1,
										isActive: currentIndex == 1,
										activeColor: activeColor,
										inactiveColor: inactiveColor,
										onTap: onTap,
									),
									  SizedBox(width: gapForCenter),

									_NavButton(
										icon: Icons.bookmark_border,
										index: 3,
										isActive: currentIndex == 3,
										activeColor: activeColor,
										inactiveColor: inactiveColor,
										onTap: onTap,
									),
									_NavButton(
										icon: Icons.person_outline,
										index: 4,
										isActive: currentIndex == 4,
										activeColor: activeColor,
										inactiveColor: inactiveColor,
										onTap: onTap,
									),
								],
							),
						),
					),

								Positioned(
									top: 0,
									child: GestureDetector(
										onTap: () => onTap?.call(2),
										child: Container(
											width: centerButtonDiameter,
											height: centerButtonDiameter,
											decoration: BoxDecoration(
												shape: BoxShape.circle,
												color: Colors.white,
												border: Border.all(color: Colors.grey.shade200, width: 2),
												boxShadow: [
													BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
												],
											),
											child: CircleAvatar(
												backgroundColor: activeColor,
												radius: centerButtonDiameter / 2 - 4,
												child: Icon(
													Icons.camera_alt,
													color: Colors.white,
													size: 26,
												),
											),
										),
									),
								),
				],
			),
		);
	}
}

class _NavButton extends StatelessWidget {
	final IconData icon;
	final int index;
	final bool isActive;
	final Color activeColor;
	final Color inactiveColor;
	final ValueChanged<int>? onTap;

	const _NavButton({
		Key? key,
		required this.icon,
		required this.index,
		required this.isActive,
		required this.activeColor,
		required this.inactiveColor,
		this.onTap,
	}) : super(key: key);

	@override
	Widget build(BuildContext context) {
		return InkWell(
			onTap: () => onTap?.call(index),
			borderRadius: BorderRadius.circular(12),
					child: SizedBox(
						width: 48,
						height: 60,
				child: Column(
					mainAxisAlignment: MainAxisAlignment.center,
					children: [
						Icon(
							icon,
							color: isActive ? activeColor : inactiveColor,
							size: 26,
						),
					],
				),
			),
		);
	}
}

