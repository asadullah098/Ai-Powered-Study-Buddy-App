// main.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'services/ai_service.dart';
import 'firebase_options.dart';
import 'services/firebase_service.dart';
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Load environment variables
  await dotenv.load(fileName: ".env");
  
  runApp(StudyBuddyApp());
}

class StudyBuddyApp extends StatelessWidget {
  const StudyBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Study Buddy',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        brightness: Brightness.light,
        useMaterial3: true,
        scaffoldBackgroundColor: Color(0xFFF7F6F3),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
            side: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
          color: Colors.white,
        ),
      ),
      home: LoginScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

// ============== Models ==============
class User {
  final String email;
  final String name;
  User({required this.email, required this.name});
}

class TodoItem {
  String id;
  String title;
  String? description;
  bool isCompleted;
  DateTime? dueDate;
  String priority;
  
  TodoItem({
    required this.id,
    required this.title,
    this.description,
    this.isCompleted = false,
    this.dueDate,
    this.priority = 'medium',
  });
}

class Notification {
  String id;
  String title;
  String message;
  DateTime timestamp;
  bool isRead;
  
  Notification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    this.isRead = false,
  });
}

class Flashcard {
  String question;
  String answer;
  bool isFlipped;
  
  Flashcard({
    required this.question,
    required this.answer,
    this.isFlipped = false,
  });
}

// ============== Login Screen ==============
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLogin = true;
  final _nameController = TextEditingController();

  void _authenticate() {
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }
    
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => DashboardScreen(
          user: User(
            email: _emailController.text,
            name: _nameController.text.isEmpty ? 'Student' : _nameController.text,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Icon(
                  Icons.layers_rounded,
                  size: 64,
                  color: Colors.black87,
                ),
                SizedBox(height: 24),
                Text(
                  'Study Buddy',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Your AI-powered learning companion',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(height: 48),
                if (!_isLogin)
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Name',
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                    ),
                  ),
                if (!_isLogin) SizedBox(height: 16),
                TextField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
                SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                  ),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _authenticate,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _isLogin ? 'Log in' : 'Sign up',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
                  ),
                ),
                SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isLogin = !_isLogin;
                    });
                  },
                  child: Text(
                    _isLogin
                        ? 'Don\'t have an account? Sign up'
                        : 'Already have an account? Log in',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============== Dashboard Screen ==============
class DashboardScreen extends StatefulWidget {
  final User user;
  
  const DashboardScreen({super.key, required this.user});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<TodoItem> todoItems = [];
  List<Notification> notifications = [];
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadSampleData();
  }

  void _loadSampleData() {
    todoItems = [
      TodoItem(
        id: '1',
        title: 'Complete Math Assignment',
        description: 'Solve problems from Chapter 5',
        dueDate: DateTime.now().add(Duration(days: 2)),
        priority: 'high',
      ),
      TodoItem(
        id: '2',
        title: 'Study for Physics Exam',
        description: 'Review chapters 1-4',
        dueDate: DateTime.now().add(Duration(days: 5)),
        priority: 'high',
      ),
      TodoItem(
        id: '3',
        title: 'Read History Chapter',
        isCompleted: true,
        priority: 'low',
      ),
    ];
    
    notifications = [
      Notification(
        id: '1',
        title: 'Assignment Due Soon',
        message: 'Math Assignment due in 2 days',
        timestamp: DateTime.now().subtract(Duration(hours: 1)),
      ),
      Notification(
        id: '2',
        title: 'Study Reminder',
        message: 'Time to review your flashcards',
        timestamp: DateTime.now().subtract(Duration(hours: 3)),
      ),
    ];
  }

  Widget _getSelectedPage() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomePage();
      case 1:
        return TodoListScreen(
          todoItems: todoItems,
          onUpdate: (items) {
            setState(() {
              todoItems = items;
            });
          },
        );
      case 2:
        return AIFeaturesScreen();
      default:
        return _buildHomePage();
    }
  }

  Widget _buildHomePage() {
    int incompleteTasks = todoItems.where((item) => !item.isCompleted).length;
    int urgentTasks = todoItems.where((item) => 
      !item.isCompleted && 
      item.dueDate != null && 
      item.dueDate!.difference(DateTime.now()).inDays <= 3
    ).length;

    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Good ${_getGreeting()}, ${widget.user.name}',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Here\'s your study overview',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 32),
          
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Tasks',
                  incompleteTasks.toString(),
                  'pending',
                  Colors.blue.shade50,
                  Colors.blue.shade700,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: _buildStatCard(
                  'Urgent',
                  urgentTasks.toString(),
                  'this week',
                  Colors.red.shade50,
                  Colors.red.shade700,
                ),
              ),
            ],
          ),
          SizedBox(height: 32),
          
          _buildSectionHeader('Quick Actions'),
          SizedBox(height: 12),
          _buildQuickAction(
            'View To-Do List',
            'Manage your tasks and assignments',
            Icons.check_circle_outline,
            Colors.blue,
            () {
              setState(() {
                _selectedIndex = 1;
              });
            },
          ),
          SizedBox(height: 8),
          _buildQuickAction(
            'AI Tools',
            'Access AI-powered study features',
            Icons.auto_awesome,
            Colors.purple,
            () {
              setState(() {
                _selectedIndex = 2;
              });
            },
          ),
          SizedBox(height: 32),
          
          _buildSectionHeader('Upcoming Deadlines'),
          SizedBox(height: 12),
          ...todoItems
              .where((item) => !item.isCompleted && item.dueDate != null)
              .take(3)
              .map((item) => _buildDeadlineCard(item)),
        ],
      ),
    );
  }

  String _getGreeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) return 'morning';
    if (hour < 17) return 'afternoon';
    return 'evening';
  }

  Widget _buildStatCard(String label, String value, String subtitle, Color bgColor, Color textColor) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              color: textColor.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 12,
              color: textColor.withOpacity(0.7),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildQuickAction(String title, String subtitle, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildDeadlineCard(TodoItem item) {
    final daysLeft = item.dueDate!.difference(DateTime.now()).inDays;
    final isUrgent = daysLeft <= 3;
    
    return Container(
      margin: EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: isUrgent ? Colors.red : Colors.blue,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                if (item.description != null) ...[
                  SizedBox(height: 4),
                  Text(
                    item.description!,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: isUrgent ? Colors.red.shade50 : Colors.blue.shade50,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '$daysLeft days',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: isUrgent ? Colors.red.shade700 : Colors.blue.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Icon(Icons.layers_rounded, color: Colors.black87, size: 24),
            SizedBox(width: 8),
            Text(
              'Study Buddy',
              style: TextStyle(
                color: Colors.black87,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(Icons.notifications_outlined, color: Colors.black87),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotificationsScreen(
                        notifications: notifications,
                        onMarkAsRead: (id) {
                          setState(() {
                            notifications.firstWhere((n) => n.id == id).isRead = true;
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
              if (notifications.any((n) => !n.isRead))
                Positioned(
                  right: 12,
                  top: 12,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(width: 4),
          PopupMenuButton<String>(
            icon: Icon(Icons.account_circle, color: Colors.black87),
            onSelected: (value) {
              if (value == 'logout') {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                );
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.user.name,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Text(
                      widget.user.email,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 18, color: Colors.grey.shade700),
                    SizedBox(width: 8),
                    Text('Log out'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _getSelectedPage(),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: Colors.grey.shade200, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          selectedItemColor: Colors.black87,
          unselectedItemColor: Colors.grey.shade500,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          backgroundColor: Colors.white,
          items: [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.check_circle_outline),
              activeIcon: Icon(Icons.check_circle),
              label: 'To-Do',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_awesome_outlined),
              activeIcon: Icon(Icons.auto_awesome),
              label: 'AI Tools',
            ),
          ],
        ),
      ),
    );
  }
}

// ============== Notifications Screen ==============
class NotificationsScreen extends StatelessWidget {
  final List<Notification> notifications;
  final Function(String) onMarkAsRead;
  
  const NotificationsScreen({super.key, required this.notifications, required this.onMarkAsRead});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifications',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
      ),
      body: notifications.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_outlined, size: 64, color: Colors.grey.shade400),
                  SizedBox(height: 16),
                  Text(
                    'No notifications',
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notif = notifications[index];
                return Container(
                  margin: EdgeInsets.only(bottom: 12),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: notif.isRead ? Colors.white : Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              notif.title,
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          if (!notif.isRead)
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                shape: BoxShape.circle,
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        notif.message,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        _formatTimestamp(notif.timestamp),
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final diff = DateTime.now().difference(timestamp);
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

// ============== To-Do List Screen ==============
class TodoListScreen extends StatefulWidget {
  final List<TodoItem> todoItems;
  final Function(List<TodoItem>) onUpdate;
  
  const TodoListScreen({super.key, required this.todoItems, required this.onUpdate});

  @override
  _TodoListScreenState createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  late List<TodoItem> items;
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    items = List.from(widget.todoItems);
  }

  List<TodoItem> get filteredItems {
    switch (_filter) {
      case 'active':
        return items.where((item) => !item.isCompleted).toList();
      case 'completed':
        return items.where((item) => item.isCompleted).toList();
      default:
        return items;
    }
  }

  void _addTodoItem() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final titleController = TextEditingController();
        final descController = TextEditingController();
        DateTime? selectedDate;
        String priority = 'medium';

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Container(
                padding: EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      'New Task',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 24),
                    TextField(
                      controller: titleController,
                      autofocus: true,
                      decoration: InputDecoration(
                        labelText: 'Task title',
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: descController,
                      decoration: InputDecoration(
                        labelText: 'Description (optional)',
                        filled: true,
                        fillColor: Colors.grey.shade50,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                      maxLines: 2,
                    ),
                    SizedBox(height: 16),
                    InkWell(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2026),
                        );
                        if (date != null) {
                          setModalState(() {
                            selectedDate = date;
                          });
                        }
                      },
                      child: Container(
                        padding: EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.calendar_today, size: 18, color: Colors.grey.shade600),
                            SizedBox(width: 12),
                            Text(
                              selectedDate == null
                                  ? 'Set due date'
                                  : '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}',
                              style: TextStyle(
                                fontSize: 15,
                                color: selectedDate == null ? Colors.grey.shade600 : Colors.black87,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    Row(
                      children: [
                        Text(
                          'Priority:',
                          style: TextStyle(fontSize: 15, color: Colors.grey.shade700),
                        ),
                        SizedBox(width: 16),
                        ...['low', 'medium', 'high'].map((p) {
                          return Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(p),
                              selected: priority == p,
                              onSelected: (selected) {
                                setModalState(() {
                                  priority = p;
                                });
                              },
                              selectedColor: _getPriorityColor(p).withOpacity(0.2),
                              checkmarkColor: _getPriorityColor(p),
                            ),
                          );
                        }),
                      ],
                    ),
                    SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        if (titleController.text.isNotEmpty) {
                          setState(() {
                            items.add(TodoItem(
                              id: DateTime.now().toString(),
                              title: titleController.text,
                              description: descController.text.isEmpty ? null : descController.text,
                              dueDate: selectedDate,
                              priority: priority,
                            ));
                          });
                          widget.onUpdate(items);
                          Navigator.pop(context);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        foregroundColor: Colors.white,
                        minimumSize: Size(double.infinity, 48),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        elevation: 0,
                      ),
                      child: Text('Add Task'),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Color _getPriorityColor(String priority) {
    switch (priority) {
      case 'high':
        return Colors.red;
      case 'medium':
        return Colors.orange;
      case 'low':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Colors.grey.shade200),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All', 'all'),
                      SizedBox(width: 8),
                      _buildFilterChip('Active', 'active'),
                      SizedBox(width: 8),
                      _buildFilterChip('Completed', 'completed'),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 8),
              IconButton(
                icon: Icon(Icons.add, color: Colors.black87),
                onPressed: _addTodoItem,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey.shade100,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: filteredItems.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline, size: 64, color: Colors.grey.shade400),
                      SizedBox(height: 16),
                      Text(
                        _filter == 'completed' ? 'No completed tasks yet' : 'No tasks yet',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      SizedBox(height: 16),
                      TextButton(
                        onPressed: _addTodoItem,
                        child: Text('Add your first task'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.all(16),
                  itemCount: filteredItems.length,
                  itemBuilder: (context, index) {
                    final item = filteredItems[index];
                    return Dismissible(
                      key: Key(item.id),
                      background: Container(
                        margin: EdgeInsets.only(bottom: 8),
                        padding: EdgeInsets.symmetric(horizontal: 20),
                        decoration: BoxDecoration(
                          color: Colors.red.shade400,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        alignment: Alignment.centerRight,
                        child: Icon(Icons.delete, color: Colors.white),
                      ),
                      direction: DismissDirection.endToStart,
                      onDismissed: (direction) {
                        setState(() {
                          items.remove(item);
                        });
                        widget.onUpdate(items);
                      },
                      child: Container(
                        margin: EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: ListTile(
                          leading: Checkbox(
                            value: item.isCompleted,
                            onChanged: (value) {
                              setState(() {
                                item.isCompleted = value!;
                              });
                              widget.onUpdate(items);
                            },
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          title: Text(
                            item.title,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w500,
                              color: item.isCompleted ? Colors.grey.shade500 : Colors.black87,
                              decoration: item.isCompleted ? TextDecoration.lineThrough : null,
                            ),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (item.description != null) ...[
                                SizedBox(height: 4),
                                Text(
                                  item.description!,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                              ],
                              if (item.dueDate != null) ...[
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.calendar_today,
                                      size: 12,
                                      color: Colors.grey.shade500,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      '${item.dueDate!.day}/${item.dueDate!.month}/${item.dueDate!.year}',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                          trailing: Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: _getPriorityColor(item.priority),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _filter == value;
    return InkWell(
      onTap: () {
        setState(() {
          _filter = value;
        });
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black87 : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Colors.black87 : Colors.grey.shade300,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? Colors.white : Colors.grey.shade700,
          ),
        ),
      ),
    );
  }
}

// ============== AI Features Screen ==============
class AIFeaturesScreen extends StatelessWidget {
  const AIFeaturesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'AI-Powered Tools',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Enhance your learning with AI',
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 24),
          _buildAIFeatureCard(
            context,
            'AI Doubt Solver',
            'Get instant answers to your questions',
            Icons.chat_bubble_outline,
            Colors.blue,
            () => Navigator.push(context, MaterialPageRoute(
              builder: (context) => DoubtSolverScreen(),
            )),
          ),
          SizedBox(height: 12),
          _buildAIFeatureCard(
            context,
            'Quiz Generator',
            'Create custom quizzes on any topic',
            Icons.quiz_outlined,
            Colors.purple,
            () => Navigator.push(context, MaterialPageRoute(
              builder: (context) => QuizGeneratorScreen(),
            )),
          ),
          SizedBox(height: 12),
          _buildAIFeatureCard(
            context,
            'Flashcards',
            'Study with interactive flashcards',
            Icons.style_outlined,
            Colors.orange,
            () => Navigator.push(context, MaterialPageRoute(
              builder: (context) => FlashcardsScreen(),
            )),
          ),
          SizedBox(height: 12),
          _buildAIFeatureCard(
            context,
            'Notes Summarizer',
            'Get concise summaries of your notes',
            Icons.summarize_outlined,
            Colors.green,
            () => Navigator.push(context, MaterialPageRoute(
              builder: (context) => NotesSummarizerScreen(),
            )),
          ),
          SizedBox(height: 12),
          _buildAIFeatureCard(
            context,
            'Resource Finder',
            'Discover relevant study materials',
            Icons.search,
            Colors.teal,
            () => Navigator.push(context, MaterialPageRoute(
              builder: (context) => ResourceFinderScreen(),
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildAIFeatureCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }
}

// ============== AI Doubt Solver Screen ==============
class DoubtSolverScreen extends StatefulWidget {
  const DoubtSolverScreen({super.key});

  @override
  _DoubtSolverScreenState createState() => _DoubtSolverScreenState();
}

class _DoubtSolverScreenState extends State<DoubtSolverScreen> {
  final TextEditingController _questionController = TextEditingController();
  final AIService _aiService = AIService();
  List<Map<String, String>> chatHistory = [];
  bool isLoading = false;

  void _askQuestion() async {
    if (_questionController.text.trim().isEmpty) return;

    final question = _questionController.text;
    
    setState(() {
      chatHistory.add({
        'role': 'user',
        'message': question,
      });
      isLoading = true;
    });

    _questionController.clear();

    try {
      final answer = await _aiService.solveDoubt(question);
      
      setState(() {
        chatHistory.add({
          'role': 'ai',
          'message': answer,
        });
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        chatHistory.add({
          'role': 'ai',
          'message': 'Sorry, I encountered an error: $e',
        });
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'AI Doubt Solver',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: chatHistory.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey.shade400),
                        SizedBox(height: 16),
                        Text(
                          'Ask me anything',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Get instant help with your studies',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: EdgeInsets.all(16),
                    itemCount: chatHistory.length,
                    itemBuilder: (context, index) {
                      final chat = chatHistory[index];
                      final isUser = chat['role'] == 'user';
                      return Align(
                        alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                        child: Container(
                          margin: EdgeInsets.only(bottom: 12),
                          padding: EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: isUser ? Colors.black87 : Colors.grey.shade100,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          constraints: BoxConstraints(
                            maxWidth: MediaQuery.of(context).size.width * 0.75,
                          ),
                          child: Text(
                            chat['message']!,
                            style: TextStyle(
                              fontSize: 15,
                              color: isUser ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
          ),
          if (isLoading)
            Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  SizedBox(width: 12),
                  Text('Thinking...', style: TextStyle(color: Colors.grey.shade600)),
                ],
              ),
            ),
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                top: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _questionController,
                    decoration: InputDecoration(
                      hintText: 'Ask your question...',
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    maxLines: null,
                    onSubmitted: (_) => _askQuestion(),
                  ),
                ),
                SizedBox(width: 8),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white, size: 20),
                    onPressed: _askQuestion,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


// ============== Quiz Generator Screen ==============
class QuizGeneratorScreen extends StatefulWidget {
  const QuizGeneratorScreen({super.key});

  @override
  _QuizGeneratorScreenState createState() => _QuizGeneratorScreenState();
}

class _QuizGeneratorScreenState extends State<QuizGeneratorScreen> {
  final TextEditingController _topicController = TextEditingController();
  final AIService _aiService = AIService();
  List<Map<String, dynamic>> quiz = [];
  int currentQuestion = 0;
  int score = 0;
  bool quizStarted = false;
  bool quizCompleted = false;
  bool isGenerating = false;

  void _generateQuiz() async {
    if (_topicController.text.trim().isEmpty) return;
    
    setState(() {
      isGenerating = true;
    });

    try {
      final generatedQuiz = await _aiService.generateQuiz(_topicController.text, 5);
      
      setState(() {
        quiz = generatedQuiz;
        quizStarted = true;
        currentQuestion = 0;
        score = 0;
        quizCompleted = false;
        isGenerating = false;
      });
    } catch (e) {
      setState(() {
        isGenerating = false;
      });
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate quiz: $e')),
      );
    }
  }

  void _selectAnswer(int index) {
    setState(() {
      quiz[currentQuestion]['selected'] = index;
    });
  }

  void _nextQuestion() {
    if (quiz[currentQuestion]['selected'] == quiz[currentQuestion]['correct']) {
      score++;
    }

    if (currentQuestion < quiz.length - 1) {
      setState(() {
        currentQuestion++;
      });
    } else {
      setState(() {
        quizCompleted = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Quiz Generator',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(20),
        child: isGenerating
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Generating quiz...', style: TextStyle(fontSize: 16)),
                  ],
                ),
              )
            : !quizStarted
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Icon(Icons.quiz_outlined, size: 64, color: Colors.purple),
                      SizedBox(height: 24),
                      Text(
                        'Generate a Quiz',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Enter a topic to create custom questions',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      SizedBox(height: 32),
                      TextField(
                        controller: _topicController,
                        decoration: InputDecoration(
                          labelText: 'Topic',
                          hintText: 'e.g., Photosynthesis, World War II',
                          filled: true,
                          fillColor: Colors.grey.shade50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _generateQuiz,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.purple,
                          foregroundColor: Colors.white,
                          minimumSize: Size(double.infinity, 48),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 0,
                        ),
                        child: Text('Generate Quiz'),
                      ),
                    ],
                  )
                : quizCompleted
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.celebration, size: 64, color: Colors.amber),
                            SizedBox(height: 24),
                            Text(
                              'Quiz Complete!',
                              style: TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Your Score',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey.shade600,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '$score/${quiz.length}',
                              style: TextStyle(
                                fontSize: 48,
                                fontWeight: FontWeight.bold,
                                color: Colors.purple,
                              ),
                            ),
                            SizedBox(height: 32),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  quizStarted = false;
                                  quiz.clear();
                                  _topicController.clear();
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black87,
                                foregroundColor: Colors.white,
                                padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Text('Create Another Quiz'),
                            ),
                          ],
                        ),
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          LinearProgressIndicator(
                            value: (currentQuestion + 1) / quiz.length,
                            backgroundColor: Colors.grey.shade200,
                            color: Colors.purple,
                          ),
                          SizedBox(height: 24),
                          Text(
                            'Question ${currentQuestion + 1} of ${quiz.length}',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade600,
                            ),
                          ),
                          SizedBox(height: 16),
                          Container(
                            padding: EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Text(
                              quiz[currentQuestion]['question'],
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          SizedBox(height: 24),
                          ...List.generate(
                            quiz[currentQuestion]['options'].length,
                            (index) {
                              final isSelected =
                                  quiz[currentQuestion]['selected'] == index;
                              return Padding(
                                padding: EdgeInsets.only(bottom: 12),
                                child: InkWell(
                                  onTap: () => _selectAnswer(index),
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? Colors.purple.withOpacity(0.1)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(
                                        color: isSelected
                                            ? Colors.purple
                                            : Colors.grey.shade300,
                                        width: isSelected ? 2 : 1,
                                      ),
                                    ),
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 24,
                                          height: 24,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: isSelected
                                                  ? Colors.purple
                                                  : Colors.grey.shade400,
                                              width: 2,
                                            ),
                                            color: isSelected
                                                ? Colors.purple
                                                : Colors.transparent,
                                          ),
                                          child: isSelected
                                              ? Icon(Icons.check,
                                                  size: 16, color: Colors.white)
                                              : null,
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: Text(
                                            quiz[currentQuestion]['options'][index],
                                            style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: isSelected
                                                  ? FontWeight.w600
                                                  : FontWeight.normal,
                                              color: Colors.black87,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          Spacer(),
                          ElevatedButton(
                            onPressed: quiz[currentQuestion]['selected'] != -1
                                ? _nextQuestion
                                : null,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.black87,
                              foregroundColor: Colors.white,
                              minimumSize: Size(double.infinity, 48),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                              elevation: 0,
                            ),
                            child: Text(
                              currentQuestion < quiz.length - 1
                                  ? 'Next Question'
                                  : 'Finish Quiz',
                            ),
                          ),
                        ],
                      ),
      ),
    );
  }
}
// ============== Flashcards Screen ==============
class FlashcardsScreen extends StatefulWidget {
  @override
  _FlashcardsScreenState createState() => _FlashcardsScreenState();
}

class _FlashcardsScreenState extends State<FlashcardsScreen> {
  final AIService _aiService = AIService();
  List<Flashcard> flashcards = [];
  int currentCard = 0;
  bool isLoading = false;

  void _generateFlashcards() async {
    final topicController = TextEditingController();
    
    final topic = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Generate Flashcards'),
        content: TextField(
          controller: topicController,
          decoration: InputDecoration(
            labelText: 'Topic',
            hintText: 'e.g., Photosynthesis, World War II',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, topicController.text),
            child: Text('Generate'),
          ),
        ],
      ),
    );

    if (topic == null || topic.trim().isEmpty) return;

    setState(() {
      isLoading = true;
    });

    try {
      final generatedCards = await _aiService.generateFlashcards(topic, 5);
      
      setState(() {
        flashcards = generatedCards.map((card) => Flashcard(
          question: card['question']!,
          answer: card['answer']!,
        )).toList();
        currentCard = 0;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to generate flashcards: $e')),
      );
    }
  }

  void _addManualFlashcard() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        final questionController = TextEditingController();
        final answerController = TextEditingController();

        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'New Flashcard',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 24),
                TextField(
                  controller: questionController,
                  decoration: InputDecoration(
                    labelText: 'Question',
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  maxLines: 2,
                ),
                SizedBox(height: 16),
                TextField(
                  controller: answerController,
                  decoration: InputDecoration(
                    labelText: 'Answer',
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  maxLines: 3,
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    if (questionController.text.isNotEmpty &&
                        answerController.text.isNotEmpty) {
                      setState(() {
                        flashcards.add(Flashcard(
                          question: questionController.text,
                          answer: answerController.text,
                        ));
                      });
                      Navigator.pop(context);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black87,
                    foregroundColor: Colors.white,
                    minimumSize: Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: Text('Add Flashcard'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _flipCard() {
    setState(() {
      flashcards[currentCard].isFlipped = !flashcards[currentCard].isFlipped;
    });
  }

  void _nextCard() {
    setState(() {
      if (currentCard < flashcards.length - 1) {
        currentCard++;
        flashcards[currentCard].isFlipped = false;
      }
    });
  }

  void _previousCard() {
    setState(() {
      if (currentCard > 0) {
        currentCard--;
        flashcards[currentCard].isFlipped = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Flashcards',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.auto_awesome, color: Colors.orange),
            onPressed: _generateFlashcards,
            tooltip: 'Generate with AI',
          ),
          IconButton(
            icon: Icon(Icons.add, color: Colors.black87),
            onPressed: _addManualFlashcard,
            tooltip: 'Add manually',
          ),
        ],
      ),
      body: isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Generating flashcards...'),
                ],
              ),
            )
          : flashcards.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.style_outlined, size: 64, color: Colors.grey.shade400),
                      SizedBox(height: 16),
                      Text(
                        'No flashcards yet',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Generate with AI or add manually',
                        style: TextStyle(color: Colors.grey.shade600),
                      ),
                      SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: _generateFlashcards,
                        icon: Icon(Icons.auto_awesome),
                        label: Text('Generate with AI'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.orange,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              : Padding(
                  padding: EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Text(
                        'Card ${currentCard + 1} of ${flashcards.length}',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      SizedBox(height: 24),
                      Expanded(
                        child: GestureDetector(
                          onTap: _flipCard,
                          child: Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(32),
                            decoration: BoxDecoration(
                              color: flashcards[currentCard].isFlipped
                                  ? Colors.orange.shade50
                                  : Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(
                                color: flashcards[currentCard].isFlipped
                                    ? Colors.orange.shade200
                                    : Colors.blue.shade200,
                                width: 2,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  flashcards[currentCard].isFlipped ? 'Answer' : 'Question',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade600,
                                  ),
                                ),
                                SizedBox(height: 24),
                                Text(
                                  flashcards[currentCard].isFlipped
                                      ? flashcards[currentCard].answer
                                      : flashcards[currentCard].question,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 24),
                                Text(
                                  'Tap to flip',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey.shade500,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton(
                            onPressed: currentCard > 0 ? _previousCard : null,
                            icon: Icon(Icons.arrow_back),
                            style: IconButton.styleFrom(
                              backgroundColor: currentCard > 0
                                  ? Colors.black87
                                  : Colors.grey.shade300,
                              foregroundColor: Colors.white,
                            ),
                          ),
                          SizedBox(width: 24),
                          IconButton(
                            onPressed: currentCard < flashcards.length - 1 ? _nextCard : null,
                            icon: Icon(Icons.arrow_forward),
                            style: IconButton.styleFrom(
                              backgroundColor: currentCard < flashcards.length - 1
                                  ? Colors.black87
                                  : Colors.grey.shade300,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
    );
  }
}

// ============== Notes Summarizer Screen ==============
class NotesSummarizerScreen extends StatefulWidget {
  @override
  _NotesSummarizerScreenState createState() => _NotesSummarizerScreenState();
}

class _NotesSummarizerScreenState extends State<NotesSummarizerScreen> {
  final TextEditingController _notesController = TextEditingController();
  final AIService _aiService = AIService();
  String summary = '';
  bool isLoading = false;

  void _summarizeNotes() async {
    if (_notesController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter some notes to summarize')),
      );
      return;
    }

    setState(() {
      isLoading = true;
      summary = '';
    });

    try {
      final result = await _aiService.summarizeNotes(_notesController.text);
      
      setState(() {
        summary = result;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        summary = 'Error: Failed to summarize notes. ${e.toString()}';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notes Summarizer',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Enter your notes',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _notesController,
              decoration: InputDecoration(
                hintText: 'Paste your notes here...',
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
              maxLines: 10,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: isLoading ? null : _summarizeNotes,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                minimumSize: Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: isLoading
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : Text('Summarize with AI'),
            ),
            if (isLoading) ...[
              SizedBox(height: 32),
              Center(
                child: Column(
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Analyzing your notes...'),
                  ],
                ),
              ),
            ],
            if (summary.isNotEmpty && !isLoading) ...[
              SizedBox(height: 32),
              Text(
                'Summary',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 16),
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Text(
                  summary,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

// ============== Resource Finder Screen (UPDATED) ==============
class ResourceFinderScreen extends StatefulWidget {
  @override
  _ResourceFinderScreenState createState() => _ResourceFinderScreenState();
}

class _ResourceFinderScreenState extends State<ResourceFinderScreen> {
  final TextEditingController _searchController = TextEditingController();
  final AIService _aiService = AIService();
  List<Map<String, String>> resources = [];
  bool isLoading = false;

  void _searchResources() async {
    if (_searchController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a topic to search')),
      );
      return;
    }

    setState(() {
      isLoading = true;
      resources = [];
    });

    try {
      final foundResources = await _aiService.findResources(_searchController.text);
      
      setState(() {
        resources = foundResources;
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to find resources: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Resource Finder',
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search for study materials...',
                      filled: true,
                      fillColor: Colors.grey.shade50,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Colors.grey.shade300),
                      ),
                      prefixIcon: Icon(Icons.search),
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    onSubmitted: (_) => _searchResources(),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  onPressed: _searchResources,
                  icon: Icon(Icons.auto_awesome),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                  ),
                  tooltip: 'Search with AI',
                ),
              ],
            ),
          ),
          Expanded(
            child: isLoading
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text('Finding resources...'),
                      ],
                    ),
                  )
                : resources.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.search, size: 64, color: Colors.grey.shade400),
                            SizedBox(height: 16),
                            Text(
                              'Search for resources',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              'Find articles, videos, and more with AI',
                              style: TextStyle(color: Colors.grey.shade600),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: resources.length,
                        itemBuilder: (context, index) {
                          final resource = resources[index];
                          return Container(
                            margin: EdgeInsets.only(bottom: 12),
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: Colors.grey.shade200),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.teal.shade50,
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        resource['type']!,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                          color: Colors.teal.shade700,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12),
                                Text(
                                  resource['title']!,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(
                                      Icons.language,
                                      size: 14,
                                      color: Colors.grey.shade500,
                                    ),
                                    SizedBox(width: 4),
                                    Text(
                                      resource['source']!,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                  ],
                                ),
                                if (resource['description'] != null) ...[
                                  SizedBox(height: 8),
                                  Text(
                                    resource['description']!,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}