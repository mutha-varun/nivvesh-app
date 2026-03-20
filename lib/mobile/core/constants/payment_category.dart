class PaymentCategories {
  static const String food = 'Food & Dining';
  static const String shopping = 'Shopping & Grocery';
  static const String transport = 'Transport & Travel';
  static const String entertainment = 'Entertainment';
  static const String bills = 'Bills & Utilities';
  static const String health = 'Health & Wellness';
  static const String investment = 'Investment & Fees';
  static const String uncategorized = 'Others';

  static const Map<String, List<String>> keywords = {
    food: [
      'zomato', 'swiggy', 'hungerbox', 'eatsure', 'magicpin', 'mcdonalds', 'kfc', 
      'starbucks', 'dominos', 'pizza', 'burger', 'subway', 'chaayos', 'chai', 
      'bakery', 'cafe', 'restaurant', 'dining'
    ],
    shopping: [
      'amazon', 'flipkart', 'myntra', 'ajio', 'meesho', 'nykaa', 'blinkit', 
      'zepto', 'instamart', 'bigbasket', 'dmart', 'reliance', 'jiomart', 
      'croma', 'h&m', 'zara', 'decathlon', 'shopping'
    ],
    transport: [
      'uber', 'ola', 'rapido', 'namma yatri', 'blusmart', 'irctc', 'indigo', 
      'air india', 'vistara', 'makemytrip', 'redbus', 'fastag', 'metro', 
      'petrol', 'hpcl', 'bpcl', 'iocl', 'shell', 'fuel'
    ],
    entertainment: [
      'netflix', 'prime video', 'hotstar', 'sonyliv', 'bookmyshow', 'pvr', 
      'inox', 'spotify', 'youtube', 'gaana', 'dream11', 'mpl', 'steam'
    ],
    bills: [
      'airtel', 'jio', 'vodafone', 'vi', 'bsnl', 'recharge', 'electricity', 
      'bill', 'insurance', 'lic', 'broadband', 'tata play', 'dth'
    ],
    health: [
      'pharmeasy', '1mg', 'apollo', 'netmeds', 'practo', 'cult.fit', 
      'hospital', 'pharmacy', 'chemist', 'lab', 'gym'
    ],
    investment: [
      'zerodha', 'groww', 'upstox', 'angel one', 'mutual fund', 'sip', 
      'stock', 'broker', 'school', 'college', 'fee'
    ],
  };

  // Dedicated UPI/VPA Identifiers (Higher priority matching)
  static const Map<String, List<String>> vpaIdentifiers = {
    food: ['@zomato', '@swiggy', '@jupiter', 'vpa:swiggy', 'vpa:zomato'],
    shopping: ['@paytmads', 'amzn', 'flipkt'],
    transport: ['@fastag', 'irctc', 'olacabs'],
  };

  static const transactionContextKeywords = [
    'upi',
    'trf to',
    'refno',
    'a/c',
    'ac no',
    'mandate',
    'towards',
  ];

  static const creditCategory = 'Credit';

  static const creditKeywordHints = [
    'credited',
    'received',
    'refund',
    'cashback',
  ];

  static const debitKeywordHints = [
    'debited',
    'deducted',
    'spent',
    'paid',
    'payment of',
    'withdrawn',
  ];
}