import 'dart:math';
import 'package:flutter/material.dart';

void main() {
  runApp(const DrunkcardApp());
}

enum GameMode { game, punishment }

class DrunkcardApp extends StatelessWidget {
  const DrunkcardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Drunkcard',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF101010),
      ),
      home: const CardGamePage(),
    );
  }
}

class CardGamePage extends StatefulWidget {
  const CardGamePage({super.key});

  @override
  State<CardGamePage> createState() => _CardGamePageState();
}

class _CardGamePageState extends State<CardGamePage>
    with SingleTickerProviderStateMixin {
  final List<String> _gameCards = [
    '古今東西',
    'なんでも',
    '牛タン',
    'ピンポンパン',
    'もりよし',
    'ローソン',
    '風船',
    'ほうれん草',
    '2丁拳銃',
    'たけのこニョッキ',
    'サンバ',
    'スーパーマリオ',
    '歌歌え',
  ];

  final List<String> _punishmentCards = [
    '自分',
    '一人指名',
    'みんな',
    '男',
    '女',
    '左隣',
    '右隣',
    '誕生日一番近い人',
    '指名乾杯',
    '全員でジャンケン',
    '全員で指差し',
    'ゲーム',
    'ペア',
    'あなたとじゃんけんをして負けた人',
    '一番飲んでない人',
    '真実か飲むか',
  ];

  GameMode _mode = GameMode.game;
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _isFront = true;
  String _currentCard = '';

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _animation = Tween<double>(
      begin: 0,
      end: pi,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _drawNewCard();
  }

  List<String> get _currentList =>
      _mode == GameMode.game ? _gameCards : _punishmentCards;

  void _drawNewCard() {
    setState(() {
      _currentList.shuffle();
      _currentCard = _currentList.first;
    });
  }

  void _flipCard() {
    if (_controller.isAnimating) return;
    if (_isFront) {
      _controller.forward().then((_) {
        setState(() => _isFront = false);
      });
    } else {
      _controller.reverse().then((_) {
        setState(() {
          _isFront = true;
          _drawNewCard();
        });
      });
    }
  }

  void _changeMode(GameMode mode) {
    if (mode == _mode) return;
    setState(() {
      _mode = mode;
      _drawNewCard();
      _isFront = true;
      _controller.reset();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _buildCardContent(bool isFront) {
    if (isFront) {
      return Center(
        child: Text(
          'タップしてカードを引く',
          style: TextStyle(
            fontSize: 28,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      );
    } else {
      return Center(
        child: Text(
          _currentCard,
          style: TextStyle(
            fontSize: 36,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final double cardWidth = MediaQuery.of(context).size.width * 0.8;
    final double cardHeight = MediaQuery.of(context).size.height * 0.5;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Drunkcard - ${_mode == GameMode.game ? 'ゲーム' : '誰が飲むか'}',
          style: TextStyle(fontSize: 22),
        ),
        centerTitle: true,
        backgroundColor: Colors.black87,
        actions: [
          PopupMenuButton<GameMode>(
            onSelected: _changeMode,
            itemBuilder: (context) => [
              const PopupMenuItem(value: GameMode.game, child: Text('🎮 ゲーム')),
              const PopupMenuItem(
                value: GameMode.punishment,
                child: Text('💀 誰が飲むか'),
              ),
            ],
          ),
        ],
      ),
      body: Center(
        child: GestureDetector(
          onTap: _flipCard,
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              final angle = _animation.value;
              final isUnder = (angle > pi / 2);
              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(angle),
                child: Container(
                  width: cardWidth,
                  height: cardHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      colors: isUnder
                          ? [Colors.purple.shade700, Colors.deepPurple.shade900]
                          : [Colors.orange.shade400, Colors.red.shade600],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black54,
                        blurRadius: 20,
                        offset: Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationY(isUnder ? pi : 0),
                    child: _buildCardContent(!isUnder),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
