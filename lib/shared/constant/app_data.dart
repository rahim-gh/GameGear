import '../model/product_model.dart';

class AppData {
  // Convert the static list of products into a list of Product objects
  static final List<Product> products = [
    Product(
      '1', // Add id
      name: 'Black Wireless RGB Gaming Mouse',
      description: '''
Experience precision and performance with this sleek black wireless gaming mouse. With RGB lighting along the edges, this mouse stands out while offering wireless convenience. Its adjustable DPI settings and fast response rate provide a seamless gaming experience, making it perfect for both casual and professional gamers. The ergonomic design ensures comfort, while the programmable buttons give you full control over your gameplay.
Key Features:
Wireless connectivity for freedom of movement.
Customizable RGB lighting with different color modes.
Adjustable DPI settings for precision targeting.
Ergonomic design with side grips for comfort.
Compatible with PC, Mac, and gaming consoles.''',
      price: 200.0,
      tags: ['mouse', 'wireless', 'gaming'],
      imagesBase64: [
        'assets/images/download__1_-removebg-preview.png'
      ], // Add image paths
      ownerUid: 'owner1',
      createdAt: DateTime.now(),
      rate: 5.0,
    ),
    Product(
      '2', // Add id
      name: 'Ergonomic Black Gaming Mouse with RGB Lighting',
      description: '''
Designed for both comfort and precision, this ergonomic black gaming mouse with side grips offers a smooth gaming experience. The subtle RGB lighting gives it a sleek aesthetic, while the precision sensor and adjustable DPI allow for accurate tracking. With customizable buttons and a wireless connection, this mouse is ideal for gamers looking for both style and functionality.
Key Features:
Ergonomic design with side grips for enhanced control.
Wireless connectivity for convenient gameplay.
Adjustable DPI for precise gaming control.
Customizable RGB lighting to match your gaming setup.
Long battery life and responsive performance.''',
      price: 350.0,
      tags: ['mouse', 'wireless', 'gaming'],
      imagesBase64: [
        'assets/images/download-removebg-preview (4).png'
      ], // Add image paths
      ownerUid: 'owner2',
      createdAt: DateTime.now(),
      rate: 2.0,
    ),
    Product(
      '3', // Add id
      name: 'High-Performance RGB Gaming PC Tower',
      description: '''
Power up your gaming experience with this high-performance gaming PC tower. Its modern design showcases RGB fans that not only cool your system but also provide a vibrant and customizable lighting effect. Built for speed and performance, this tower includes the latest processors and graphics cards, ensuring smooth gameplay at high settings. Whether you're into competitive gaming or high-end video editing, this PC tower delivers unmatched performance and style.
Key Features:
High-speed cooling system with RGB fans.
Transparent side panel for showcasing internal components.
Latest generation processor and powerful graphics card.
Ample storage space with SSD and HDD options.
Customizable RGB lighting for a personalized setup.''',
      price: 800.0,
      tags: ['pc', 'gaming', 'rgb'],
      imagesBase64: ['assets/images/OIP (1).jpg'], // Add image paths
      ownerUid: 'owner3',
      createdAt: DateTime.now(),
      rate: 1.0,
    ),
    Product(
      '4', // Add id
      name: 'Mars Gaming RGB Wired Controller',
      description: '''
The Mars Gaming controller is built for avid gamers who value style and precision. With its transparent shell and dynamic RGB lighting, this controller is a showstopper in any setup. It features ergonomic, responsive controls, ensuring swift reactions and a comfortable grip for hours of play. Designed for compatibility with multiple platforms, it delivers an immersive experience with customizable buttons and smooth analog sticks.
Key Features:
Transparent body with built-in RGB lighting.
Ergonomic design with anti-slip grip.
Responsive analog sticks and customizable buttons.
Compatible with PC, PlayStation, and Android devices.
Plug-and-play functionality.''',
      price: 550.0,
      tags: ['controller', 'gaming', 'rgb'],
      imagesBase64: ['assets/images/OIP (3).jpg'], // Add image paths
      ownerUid: 'owner4',
      createdAt: DateTime.now(),
      rate: 0.0,
    ),
    Product(
      '5', // Add id
      name: 'Pink Gaming Headset with RGB Surround Sound',
      description: '''
Elevate your gaming experience with this stylish pink gaming headset, featuring RGB lighting for a vibrant, customizable glow. Equipped with a high-fidelity sound system and surround sound capabilities, it immerses you in crystal-clear audio, giving you a competitive edge in any game. The ergonomic design and cushioned ear cups ensure maximum comfort during long gaming sessions. Its flexible, noise-canceling microphone allows for clear communication with teammates.
Key Features:
50mm speaker drivers for superior sound quality.
Adjustable RGB lighting with multiple color options.
Noise-canceling microphone for clear in-game communication.
Comfortable over-ear design with soft cushioning.
Compatible with PC, PlayStation, Xbox, and other platforms.''',
      price: 400.0,
      tags: ['headset', 'gaming', 'rgb'],
      imagesBase64: [
        'assets/images/th-removebg-preview.png'
      ], // Add image paths
      ownerUid: 'owner5',
      createdAt: DateTime.now(),
      rate: 3.0,
    ),
    Product(
      '6', // Add id
      name: 'RGB Gaming Headset with Surround Sound',
      description: '''
Immerse yourself in high-quality sound with this RGB gaming headset. Designed for gamers, this headset delivers crystal-clear audio with deep bass and 7.1 surround sound for an enhanced gaming experience. The adjustable headband and cushioned ear cups ensure maximum comfort for long gaming sessions. With a detachable noise-canceling microphone, team communication is clearer than ever. Compatible with PC, PS5, Xbox, and more, this gaming headset is a must-have for any serious gamer.

Key Features:
- Dynamic RGB lighting for an immersive gaming experience.
- 7.1 surround sound for high-quality audio.
- Adjustable headband and cushioned ear cups for comfort.
- Noise-canceling detachable microphone for clear communication.
- Multi-platform compatibility with PC, PS5, Xbox, and more.''',
      price: 120.0,
      tags: ['headset', 'gaming', 'rgb'],
      imagesBase64: [
        'assets/images/1000025012-removebg-preview.png'
      ], // Add image paths
      ownerUid: 'owner6',
      createdAt: DateTime.now(),
      rate: 4.5,
    ),
    Product(
      '7', // Add id
      name: 'High-Precision RGB Gaming Mouse',
      description: '''
Upgrade your gaming setup with this high-precision RGB gaming mouse. Designed for competitive gamers, it features an ergonomic design, customizable buttons, and ultra-responsive sensors for lightning-fast accuracy. The adjustable DPI settings allow you to switch between different sensitivity levels for precise control in any game. With dynamic RGB lighting, this mouse adds a stylish touch to your gaming rig.

Key Features:
- Adjustable DPI settings for customizable sensitivity.
- Ergonomic design for comfortable extended gameplay.
- Programmable buttons for personalized controls.
- High-precision sensor for ultra-fast response.
- Customizable RGB lighting for an immersive gaming experience.''',
      price: 60.0,
      tags: ['mouse', 'gaming', 'rgb'],
      imagesBase64: [
        'assets/images/1000025004-removebg-preview (1).png'
      ], // Add image paths
      ownerUid: 'owner7',
      createdAt: DateTime.now(),
      rate: 4.7,
    ),
    Product(
      '8', // Add id
      name: 'Programmable RGB Gaming Mouse with Side Buttons',
      description: '''
Enhance your gaming experience with this programmable RGB gaming mouse, designed for MMO, MOBA, and FPS gamers. With multiple customizable side buttons, you can program macros and keybindings for quicker in-game actions. The ergonomic design ensures comfort for long gaming sessions, while the high-precision sensor delivers exceptional accuracy. Adjustable DPI settings allow you to fine-tune sensitivity on the fly, and the dynamic RGB lighting lets you personalize your setup.

Key Features:
- 12 programmable side buttons for enhanced control.
- Adjustable DPI for precision aiming and movement.
- Ergonomic design for extended comfort.
- High-precision sensor for ultra-responsive performance.
- Customizable RGB lighting for a stylish setup.''',
      price: 75.0,
      tags: ['mouse', 'gaming', 'rgb'],
      imagesBase64: [
        'assets/images/1000025002-removebg-preview.png'
      ], // Add image paths
      ownerUid: 'owner8',
      createdAt: DateTime.now(),
      rate: 4.8,
    ),
    Product(
      '9', // Add id
      name: 'Surround Sound RGB Gaming Headset',
      description: '''
Experience high-fidelity audio with this surround sound RGB gaming headset. Designed for immersive gameplay, it features a noise-canceling microphone, dynamic RGB lighting, and ultra-soft ear cushions for all-day comfort. The high-precision audio drivers deliver deep bass and crisp sound for competitive gaming, music, and streaming. The flexible, adjustable design ensures a perfect fit, while multi-platform compatibility makes it ideal for PC, PS5, Xbox, and more.

Key Features:
- 7.1 surround sound for immersive audio.
- Noise-canceling microphone for clear communication.
- Ultra-soft ear cushions for maximum comfort.
- Dynamic RGB lighting with customizable effects.
- Multi-platform compatibility with PC, PS5, Xbox, and more.''',
      price: 130.0,
      tags: ['headset', 'gaming', 'rgb'],
      imagesBase64: [
        'assets/images/1000025013-removebg-preview.png'
      ], // Add image paths
      ownerUid: 'owner9',
      createdAt: DateTime.now(),
      rate: 4.9,
    ),
    Product(
      '10', // Add id
      name: 'Mechanical RGB Gaming Keyboard',
      description: '''
Take your gaming experience to the next level with this mechanical RGB gaming keyboard. Designed for precision and durability, this keyboard features responsive mechanical switches for lightning-fast key presses. The customizable RGB lighting enhances your setup, while the ergonomic design ensures comfort during long gaming sessions. Anti-ghosting and full-key rollover provide reliable performance, making it the perfect choice for competitive gamers.

Key Features:
- Mechanical switches for fast and precise keystrokes.
- Customizable RGB backlighting for a stylish setup.
- Anti-ghosting and full-key rollover for accurate inputs.
- Durable construction for long-lasting performance.
- Ergonomic design for comfortable gaming sessions.''',
      price: 90.0,
      tags: ['keyboard', 'gaming', 'rgb'],
      imagesBase64: [
        'assets/images/1000025011-removebg-preview.png'
      ], // Add image paths
      ownerUid: 'owner10',
      createdAt: DateTime.now(),
      rate: 4.8,
    ),
    Product(
      '11', // Add id
      name: 'Ergonomic RGB Gaming Keyboard with Wrist Rest',
      description: '''
Enhance your gaming setup with this ergonomic RGB gaming keyboard featuring a unique design and wrist rest for added comfort. Built for gamers, this keyboard provides tactile and responsive keys, customizable RGB lighting, and a durable construction. The anti-ghosting technology ensures every keystroke is registered accurately, making it ideal for both casual and competitive gaming.

Key Features:
- Ergonomic design with an integrated wrist rest.
- Customizable RGB backlighting for an immersive experience.
- Tactile and responsive keys for precise input.
- Anti-ghosting and full-key rollover for optimal performance.
- Durable build for long-lasting use.''',
      price: 110.0,
      tags: ['keyboard', 'gaming', 'rgb'],
      imagesBase64: [
        'assets/images/1000025010-removebg-preview.png'
      ], // Add image paths
      ownerUid: 'owner11',
      createdAt: DateTime.now(),
      rate: 4.7,
    ),
    Product(
      '12', // Add id
      name: 'Wired Gaming Headset with Noise Isolation',
      description: '''
Immerse yourself in your games with this wired gaming headset featuring powerful sound and noise isolation. Designed for comfort and durability, this headset includes cushioned ear cups and an adjustable headband for extended gaming sessions. The noise-canceling microphone ensures crystal-clear communication with your teammates, while the high-quality drivers deliver deep bass and crisp audio.

Key Features:
- Noise-isolating ear cups for an immersive experience.
- Noise-canceling microphone for clear voice chat.
- Comfortable cushioned ear pads and adjustable headband.
- High-quality drivers for powerful sound performance.
- Multi-platform compatibility with PC, PS5, Xbox, and more.''',
      price: 85.0,
      tags: ['headset', 'gaming'],
      imagesBase64: [
        'assets/images/1000025014-removebg-preview.png'
      ], // Add image paths
      ownerUid: 'owner12',
      createdAt: DateTime.now(),
      rate: 4.6,
    ),
    Product(
      '13', // Add id
      name: 'Thrustmaster Ferrari Racing Wheel Red Legend Edition',
      description: '''
Take your racing experience to the next level with the Thrustmaster Ferrari Racing Wheel Red Legend Edition. Designed for precision and realism, this racing wheel features a rubber-coated grip for enhanced control, responsive pedals, and a programmable button layout for a customized driving experience. Whether you're playing on PC or PlayStation, this officially licensed Ferrari wheel ensures an immersive and thrilling ride.

Key Features:
- Officially licensed Ferrari racing wheel.
- Rubber-coated grip for enhanced control and comfort.
- Responsive pedals for realistic acceleration and braking.
- Programmable buttons for a customizable experience.
- Compatible with PC and PlayStation consoles.''',
      price: 180.0,
      tags: ['racing wheel', 'gaming'],
      imagesBase64: [
        'assets/images/download__2_-removebg-preview.png'
      ], // Add image paths
      ownerUid: 'owner13',
      createdAt: DateTime.now(),
      rate: 4.7,
    ),
    Product(
      '14', // Add id
      name: 'Universal Racing Wheel with Pedals',
      description: '''
Experience the thrill of racing with this universal racing wheel and pedal set. Designed for precision and control, this racing wheel features a comfortable grip, responsive pedals, and a realistic driving experience. Compatible with multiple platforms, it provides immersive gameplay whether you're racing on PC, PlayStation, or Xbox. 

Key Features:
- Ergonomic racing wheel design for enhanced grip and comfort.
- Responsive pedal set for realistic acceleration and braking.
- Multiple programmable buttons for customization.
- Wide compatibility with PC, PlayStation, and Xbox.
- Sturdy and durable construction for long-lasting performance.''',
      price: 150.0,
      tags: ['racing wheel', 'gaming'],
      imagesBase64: [
        'assets/images/OIP__5_-removebg-preview.png'
      ], // Add image paths
      ownerUid: 'owner14',
      createdAt: DateTime.now(),
      rate: 4.5,
    ),
    Product(
      '15', // Add id
      name: 'Advanced RGB Mechanical Gaming Keyboard',
      description: '''
Enhance your gaming setup with this advanced RGB mechanical gaming keyboard, designed for ultimate precision and durability. Featuring fully customizable RGB backlighting, mechanical switches for tactile feedback, and dedicated macro keys for a competitive edge, this keyboard is perfect for both casual and professional gamers. 

Key Features:
- Mechanical key switches for responsive and accurate keystrokes.
- Customizable RGB backlighting for a personalized gaming experience.
- Dedicated macro and function keys for advanced gaming control.
- Ergonomic wrist rest for extended comfort during long gaming sessions.
- Durable construction with anti-ghosting and N-key rollover.''',
      price: 120.0,
      tags: ['keyboard', 'gaming', 'rgb'],
      imagesBase64: [
        'assets/images/OIP-removebg-preview (2).png'
      ], // Add image paths
      ownerUid: 'owner15',
      createdAt: DateTime.now(),
      rate: 4.8,
    ),
    Product(
      '16', // Add id
      name: 'KOTION EACH K5 RGB Gaming Headset',
      description: '''
Immerse yourself in the world of gaming with the KOTION EACH K5 RGB Gaming Headset. Designed for ultimate comfort and an immersive sound experience, this headset features high-quality stereo sound, noise-isolating ear cushions, and a flexible noise-canceling microphone. The RGB lighting on the ear cups enhances your gaming setup with a futuristic look.

Key Features:
- High-fidelity stereo sound with deep bass for an immersive experience.
- RGB LED lighting for a stylish gaming aesthetic.
- Soft over-ear cushions for extended comfort.
- Noise-canceling microphone for clear in-game communication.
- Universal compatibility with PC, PS4, Xbox, and more.''',
      price: 60.0,
      tags: ['headset', 'gaming', 'rgb'],
      imagesBase64: [
        'assets/images/download-removebg-preview (5).png'
      ], // Add image paths
      ownerUid: 'owner16',
      createdAt: DateTime.now(),
      rate: 4.7,
    ),
  ];
}
