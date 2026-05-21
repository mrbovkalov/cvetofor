import 'dart:convert';

import 'package:webview_flutter/webview_flutter.dart';

class CartUtils {
  final Function()? onItemAdded;
  final Function(int)? onCartCountUpdated;

  CartUtils({this.onItemAdded, this.onCartCountUpdated});

  void handleAddItem(String message) {
    print('📨 Получено сообщение из WebView: $message');

    try {
      if (message.startsWith('{') && message.endsWith('}')) {
        final Map<String, dynamic> data = json.decode(message);
        _showAddedToCart();
      } else if (message == 'item_added_basic') {
        _showAddedToCart();
      }
    } catch (e) {
      print('❌ Ошибка обработки сообщения: $e');
    }
  }

  void handleCartCount(String countText) {
    print('🔢 Получено количество товаров: $countText');

    try {
      final count =
          int.tryParse(countText.replaceAll(RegExp(r'[^\d]'), '')) ?? 0;
      print('🛒 Количество товаров в корзине: $count');

      onCartCountUpdated?.call(count);
    } catch (e) {
      print('❌ Ошибка парсинга количества товаров: $e');
    }
  }

  void _showAddedToCart() {
    print('🎯 Товар добавлен в корзину');
    onItemAdded?.call();
  }

  void _processCartData(Map<String, dynamic> data) {
    final cleanedData = {
      'type': data['type'],
      'product': _cleanText(data['product']),
      'price': _extractPrice(_cleanText(data['price'])),
      'timestamp': data['timestamp'],
      'element': data['element'],
    };

    print('🛒 Очищенные данные корзины:');
    print('   Тип: ${cleanedData['type']}');
    print('   Товар: ${cleanedData['product']}');
    print('   Цена: ${cleanedData['price']}');
    print('   Время: ${cleanedData['timestamp']}');
    print('   Элемент: ${cleanedData['element']}');

    _showAddedToCart();
  }

  String _cleanText(String text) {
    if (text.isEmpty) return text;
    return text
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'\n'), '')
        .replaceAll(RegExp(r'\r'), '')
        .trim();
  }

  String _extractPrice(String priceText) {
    if (priceText.isEmpty) return '0';
    final priceRegex = RegExp(r'(\d[\d\s]*)\s*р\.');
    final match = priceRegex.firstMatch(priceText);
    if (match != null) {
      final cleanPrice = match.group(1)!.replaceAll(' ', '');
      return '$cleanPrice руб';
    }
    return priceText;
  }

  void _addToCart(Map<String, dynamic> item) {
    print(
      '🎯 Добавляем товар в корзину: ${item['product']} за ${item['price']}',
    );
    _showAddedToCart();
  }

  static Future<void> injectCartCounterListener(
    WebViewController controller,
  ) async {
    const cartCounterScript = '''
    function trackCartCounter() {
      function updateCartCount() {
        const cartCounter = document.querySelector('span.header__control-value');
        
        if (cartCounter) {
          const count = cartCounter.textContent.trim();
          console.log('🛒 Количество товаров в корзине:', count);
          
          if (window.FlutterCartCounter) {
            FlutterCartCounter.postMessage(count);
          }
        }
      }
      
      updateCartCount();

      const observer = new MutationObserver(function(mutations) {
        mutations.forEach(function(mutation) {
          if (mutation.type === 'childList' || mutation.type === 'characterData') {
            updateCartCount();
          }
        });
      });
      
      observer.observe(document.body, {
        childList: true,
        subtree: true,
        characterData: true
      });
      
      document.addEventListener('click', function() {
        setTimeout(updateCartCount, 500);
      });
    }
    
    trackCartCounter();
    console.log('✅ Cart counter tracking activated');
  ''';

    try {
      await controller.runJavaScript(cartCounterScript);
      print('✅ Cart counter listener внедрен');
    } catch (e) {
      print('❌ Ошибка внедрения cart counter listener: $e');
    }
  }
}
