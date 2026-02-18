import 'package:flutter/material.dart';

class EntrancePage extends StatefulWidget {
  const EntrancePage({super.key});

  @override
  State<EntrancePage> createState() => _EntrancePageState();
}

class _EntrancePageState extends State<EntrancePage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;
  bool _showBasket = false;
  double _dragDistance = 0.0;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _opacityAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/shmot.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Image centered
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: Image.asset(
                    "assets/images/rynok.png",
                    width: double.infinity,
                    height: 300,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 60),
              // Animated text
              GestureDetector(
                onHorizontalDragStart: (details) {
                  _dragDistance = 0.0;
                },
                onHorizontalDragUpdate: (details) {
                  _dragDistance += details.delta.dx;
                },
                onHorizontalDragEnd: (details) {
                  if (_dragDistance > 50) { // Threshold for swipe right
                    setState(() => _showBasket = true);
                  }
                },
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: FadeTransition(
                    opacity: _opacityAnimation,
                    child: Text(
                      'к покупкам',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 48,
                            shadows: [
                              Shadow(
                                color: Colors.black.withOpacity(0.5),
                                blurRadius: 8,
                                offset: const Offset(2, 2),
                              ),
                            ],
                          ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              if (_showBasket)
                AnimatedOpacity(
                  opacity: _showBasket ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 500),
                  child: Icon(
                    Icons.shopping_cart,
                    size: 50,
                    color: Colors.white,
                  ),
                ),
              const SizedBox(height: 30),
              // Arrow button
              GestureDetector(
                onTap: () {
                  Navigator.pushReplacementNamed(context, '/home');
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.arrow_forward,
                    size: 32,
                    color: Colors.blue.shade600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
