import 'dart:io';

void main() {
  ShoppingMall shoppingMall = ShoppingMall();
  shoppingMall.start();
}

class Product {
  String name;
  int price;
  
  Product(this.name, this.price);
}

class CartItem {
  Product product;
  int quantity;
  
  CartItem(this.product, this.quantity);
}

class ShoppingMall {
  List<Product> products = [];
  List<CartItem> cartItems = [];
  int totalPrice = 0;
  bool isRunning = true;
  
  ShoppingMall() {
    // 상품 초기화
    products.add(Product('셔츠', 45000));
    products.add(Product('원피스', 30000));
    products.add(Product('반팔티', 35000));
    products.add(Product('반바지', 38000));
    products.add(Product('양말', 5000));
  }
  
  void start() {
    print('쇼핑몰에 오신 것을 환영합니다!');
    
    while (isRunning) {
      printMenu();
      
      String? input = stdin.readLineSync();
      
      processMenuSelection(input);
    }
  }
  
  void printMenu() {
    print('\n원하시는 기능을 선택해주세요:');
    print('1. 상품 목록 보기');
    print('2. 장바구니에 상품 담기');
    print('3. 장바구니 확인');
    print('4. 쇼핑몰 종료');
    print('6. 장바구니 초기화');
  }
  
  void processMenuSelection(String? input) {
    switch (input) {
      case '1':
        showProducts();
        break;
      case '2':
        addToCart();
        break;
      case '3':
        showCart();
        break;
      case '4':
        confirmExit();
        break;
      case '6':
        clearCart();
        break;
      default:
        print('지원하지 않는 기능입니다! 다시 시도해 주세요..');
    }
  }
  
  void showProducts() {
    print('\n===== 상품 목록 =====');
    for (var product in products) {
      print('${product.name} / ${product.price}원');
    }
  }
  
  void addToCart() {
    try {
      print('\n장바구니에 담을 상품 이름을 입력해주세요:');
      String? productName = stdin.readLineSync();
      
      // 상품명이 비어있거나 null인 경우 체크
      if (productName == null || productName.trim().isEmpty) {
        print('입력값이 올바르지 않아요!');
        return;
      }
      
      // 입력한 상품이 존재하는지 확인
      Product? selectedProduct;
      bool productExists = false;
      
      for (var product in products) {
        if (product.name == productName) {
          selectedProduct = product;
          productExists = true;
          break;
        }
      }
      
      if (!productExists || selectedProduct == null) {
        print('입력값이 올바르지 않아요!');
        return;
      }
      
      print('상품 개수를 입력해주세요:');
      String? countInput = stdin.readLineSync();
      
      // 수량 입력값이 비어있거나 null인 경우 체크
      if (countInput == null || countInput.trim().isEmpty) {
        print('입력값이 올바르지 않아요!');
        return;
      }
      
      int count;
      try {
        count = int.parse(countInput);
        if (count <= 0) {
          print('0개보다 많은 개수의 상품만 담을 수 있어요!');
          return;
        }
      } catch (e) {
        print('입력값이 올바르지 않아요!');
        return;
      }
      
      // 장바구니에 상품 추가 로직
      int addedPrice = selectedProduct.price * count;
      totalPrice += addedPrice;
      
      // 이미 장바구니에 있는 상품인지 확인
      bool itemExists = false;
      for (var item in cartItems) {
        if (item.product.name == productName) {
          item.quantity += count;
          itemExists = true;
          break;
        }
      }
      
      // 새로운 상품이면 장바구니에 추가
      if (!itemExists) {
        cartItems.add(CartItem(selectedProduct, count));
      }
      
      print('장바구니에 상품이 담겼어요!');
    } catch (e) {
      print('오류가 발생했습니다. 다시 시도해주세요: $e');
    }
  }
  
  void showCart() {
    if (cartItems.isEmpty) {
      print('장바구니에 담긴 상품이 없습니다.');
      return;
    }
    
    // 상품 이름 리스트 생성
    List<String> itemNames = [];
    for (var item in cartItems) {
      itemNames.add('${item.product.name}(${item.quantity}개)');
    }
    
    String itemList = itemNames.join(', ');
    print('장바구니에 $itemList가 담겨있네요. 총 ${totalPrice}원 입니다!');
  }
  
  void confirmExit() {
    print('정말 종료하시겠습니까? (종료하려면 5를 입력하세요)');
    String? input = stdin.readLineSync();
    
    if (input == '5') {
      exitShop();
    } else {
      print('종료하지 않습니다.');
    }
  }
  
  void exitShop() {
    print('이용해 주셔서 감사합니다 ~ 안녕히 가세요!');
    isRunning = false;
  }
  
  void clearCart() {
    if (cartItems.isEmpty || totalPrice == 0) {
      print('이미 장바구니가 비어있습니다.');
    } else {
      cartItems.clear();
      totalPrice = 0;
      print('장바구니를 초기화합니다.');
    }
  }
}