# 🧼 Good Dismissible

A better `Dismissible` experience for Flutter — precise, polished, and visually clean.  
Ideal for cards, lists, and swipe-to-delete interactions that need to **look as good as they feel**.

![Good Dismissible demo](https://raw.githubusercontent.com/ZianFahrudy/good_dismissable/refs/heads/master/assets/preview.gif) <!-- Optional GIF demo if available -->

---

## ✨ Features

- ✅ **Clean border radius handling**
- ✅ **Classic swipe-to-dismiss with animated background**
- ✅ **LinkedIn-style reveal action that snaps open and stays tappable**
- ✅ **Customizable colors, icons, text, and action widgets**
- ✅ **Can disable swipe left or swipe right independently**
- ✅ **Drop-in replacement for Flutter’s `Dismissible`**

---

## 📦 Installation

Add the following to your `pubspec.yaml`:

```yaml
dependencies:
  good_dismissable: ^1.1.0
```

## 📦 Import the Package

```dart
import 'package:good_dismissable/good_dismissable.dart';
```

## 📦 Example

### Classic dismiss

```dart
GoodDismissableVariants.delete(
  onDismissed: () => removeItem(),
  child: const ListTile(title: Text('Swipe to delete')),
)
```

### LinkedIn-style reveal action

```dart
GoodDismissableVariants.linkedInDelete(
  onActionPressed: () => removeItem(),
  child: const ListTile(title: Text('Swipe left to reveal delete')),
)
```

### Fully customized reveal action

```dart
GoodDismissable(
  swipeBehavior: GoodDismissableSwipeBehavior.reveal,
  enableSwipeToLeft: true,
  enableSwipeToRight: false,
  backgroundColor: const Color(0xFFD11124),
  borderRadius: 20,
  revealActionExtent: 104,
  onActionPressed: () => removeItem(),
  actionContent: const Column(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(Icons.delete_outline, color: Colors.white, size: 28),
      SizedBox(height: 6),
      Text(
        'Delete',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    ],
  ),
  child: const ListTile(title: Text('Custom reveal action')),
)
```

### Full app example

```dart
class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<EmailItem> emails = List.generate(
    10,
    (index) => EmailItem(
      id: 'email_$index',
      title: 'Email ${index + 1}',
      subtitle: 'This is a sample email content for item ${index + 1}...',
      isRead: index % 3 == 0,
    ),
  );

  void _removeEmail(String emailId) {
    setState(() {
      emails.removeWhere((email) => email.id == emailId);
    });
  }

  void _markAsRead(String emailId) {
    setState(() {
      final index = emails.indexWhere((email) => email.id == emailId);
      if (index != -1) {
        emails[index] = emails[index].copyWith(isRead: true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // TRY THIS: Try changing the color here to a specific color (to
        // Colors.amber, perhaps?) and trigger a hot reload to see the AppBar
        // change color while the other colors stay the same.
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: ListView.builder(
        itemCount: emails.length,
        itemBuilder: (context, index) {
          final email = emails[index];

          // Different card types based on index for demonstration
          if (index % 4 == 0) {
            // Classic delete variant
            return GoodDismissableVariants.delete(
              key: ValueKey(email.id),
              enableSwipeToLeft: false,
              onDismissed: () => _removeEmail(email.id),
              child: _buildEmailTile(email, index),
            );
          } else if (index % 4 == 1) {
            // Archive variant
            return GoodDismissableVariants.archive(
              key: ValueKey(email.id),
              enableSwipeToRight: false,
              onDismissed: () => _removeEmail(email.id),
              child: _buildEmailTile(email, index),
            );
          } else if (index % 4 == 2) {
            // Custom variant with progress callback
            return GoodDismissable(
              key: ValueKey(email.id),
              backgroundColor: Colors.orange,
              cardOffset: 12.0,
              initialScale: 0.92,
              onDismissed: () => _markAsRead(email.id),
              onSwipeProgress: (progress) {
                // You can use this for custom animations or haptic feedback
                if (progress > 0.5) {
                  // Trigger haptic feedback or other actions
                }
              },
              backgroundContent: Row(
                children: [
                  Expanded(
                    child: Container(
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.only(left: 20),
                      child: const Text(
                        'Mark Important',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    child: const Icon(
                      Icons.star,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
              child: _buildEmailTile(email, index),
            );
          }

          return GoodDismissableVariants.linkedInDelete(
            key: ValueKey(email.id),
            onActionPressed: () => _removeEmail(email.id),
            child: _buildEmailTile(email, index),
          );
        },
      ),
    );
  }

  Widget _buildEmailTile(EmailItem email, int index) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: email.isRead ? Colors.grey : Colors.blue,
        child: Text(
          '${index + 1}',
          style: const TextStyle(color: Colors.white),
        ),
      ),
      title: Text(
        email.title,
        style: TextStyle(
          fontWeight: email.isRead ? FontWeight.normal : FontWeight.bold,
        ),
      ),
      subtitle: Text(
        email.subtitle,
        style: TextStyle(color: email.isRead ? Colors.grey : Colors.black87),
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (!email.isRead)
            Container(
              width: 8,
              height: 8,
              decoration: const BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
              ),
            ),
          const SizedBox(width: 8),
          const Icon(Icons.arrow_forward_ios, size: 16),
        ],
      ),
    );
  }
}
```

You can also control the swipe direction directly:

```dart
GoodDismissable(
  enableSwipeToLeft: false,
  enableSwipeToRight: true,
  onDismissed: () {},
  child: const ListTile(title: Text('Swipe right only')),
)
```

For a LinkedIn-style action that stops, stays open, and can be tapped:

```dart
GoodDismissableVariants.linkedInDelete(
  onActionPressed: () {},
  child: const ListTile(title: Text('Swipe left to reveal delete')),
)
```

## 🧩 Main API

- `GoodDismissableSwipeBehavior.dismiss`: classic swipe-to-dismiss behavior.
- `GoodDismissableSwipeBehavior.reveal`: swipe opens an action pane and waits for a tap.
- `enableSwipeToLeft` and `enableSwipeToRight`: toggle each swipe direction independently.
- `backgroundContent`: custom background for classic dismiss behavior.
- `actionContent`: custom action widget for reveal behavior.
- `onDismissed`: called after a classic dismiss finishes.
- `onActionPressed`: called when the revealed action is tapped.

## Issues & Suggestions

If you encounter any issue you or want to leave a suggestion you can do it by filling an [issue](https://github.com/ZianFahrudy/good_dismissable/issues).

### Thank you for the support!
