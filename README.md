# SnappingCollectionView

A custom `UICollectionViewFlowLayout` that provides smooth snapping behavior for horizontal scrolling collection views. This layout automatically centers cells and provides a paging-like experience with customizable snapping parameters.

## Features

- 🎯 **Automatic Cell Centering**: Cells automatically snap to the center of the collection view
- ⚡ **Smooth Scrolling**: Configurable velocity and distance thresholds for responsive snapping
- 🎛️ **Customizable Parameters**: Fine-tune snapping behavior with multiple configuration options
- 📱 **iOS Native**: Built with UIKit and follows iOS design patterns
- 🔄 **Delegate Support**: Get notified when snapping occurs for haptic feedback or other actions

## Installation

### Manual Installation

1. Download the `SnappingFlowLayout.swift` file
2. Add it to your Xcode project
3. Import and use in your view controller

## Quick Start

### Basic Setup

```swift
import UIKit

class ViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, SnappingFlowLayoutDelegate {
    
    private lazy var collectionView: UICollectionView = {
        let layout = SnappingFlowLayout()
        layout.scrollDirection = .horizontal
        layout.itemSize = CGSize(width: 250, height: 300)
        layout.snappingDelegate = self
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .systemBackground
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "cell")
        
        // ⚠️ IMPORTANT: Essential for smooth snapping behavior
        collectionView.decelerationRate = .fast
        
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(collectionView)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            collectionView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            collectionView.heightAnchor.constraint(equalToConstant: 350),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    // MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 20
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = .systemBlue
        
        // Configure your cell content here
        let label = UILabel()
        cell.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: cell.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: cell.centerYAnchor)
        ])
        label.text = "\(indexPath.item)"
        label.textColor = .white
        label.font = .systemFont(ofSize: 36, weight: .bold)
        
        return cell
    }
    
    // MARK: - SnappingFlowLayoutDelegate
    func collectionView(_ collectionView: UICollectionView, didSnapTo indexPath: IndexPath) {
        // Add haptic feedback or other actions when snapping occurs
        let feedbackGenerator = UISelectionFeedbackGenerator()
        feedbackGenerator.selectionChanged()
    }
}
```

## Configuration Options

The `SnappingFlowLayout` provides several customizable parameters to fine-tune the snapping behavior:

### Search Multiplier
```swift
layout.searchMultiplier = 1.5  // Default: 1.5
```
- **Purpose**: Determines how far around the proposed area to look for candidate cells
- **Higher values**: More robust for fast flicks with large momentum
- **Lower values**: More precise but may miss cells during very fast scrolling

### Velocity Threshold
```swift
layout.velocityThreshold = 0.2  // Default: 0.2
```
- **Purpose**: The velocity threshold above which snapping to next/previous item is considered
- **Lower values**: Easier to trigger a "flick" (even on gentle swipes)
- **Higher values**: Only really fast swipes are treated as flicks

### Distance Threshold Multiplier
```swift
layout.distanceThresholdMultiplier = 0.75  // Default: 0.75
```
- **Purpose**: Determines the maximum drag distance allowed to trigger snapping to next/previous item
- **Larger values**: Even relatively bigger drags still count as "tiny," so more swipes get promoted to force next/previous
- **Smaller values**: Only really short drags are considered "tiny," reducing sensitivity

## Important Notes

### ⚠️ Essential Configuration

**`collectionView.decelerationRate = .fast`** is **ESSENTIAL** for proper snapping behavior. Without this setting, the collection view will not decelerate quickly enough for the snapping algorithm to work effectively.

### Delegate Usage

Implement the `SnappingFlowLayoutDelegate` protocol to receive notifications when snapping occurs:

```swift
protocol SnappingFlowLayoutDelegate: AnyObject {
    func collectionView(_ collectionView: UICollectionView, didSnapTo indexPath: IndexPath)
}
```

This is perfect for:
- Adding haptic feedback
- Updating UI indicators
- Logging user interactions
- Triggering animations

### Layout Requirements

- **Scroll Direction**: Currently optimized for `.horizontal` scrolling
- **Item Size**: Set appropriate `itemSize` for your cells
- **Minimum Line Spacing**: Configure `minimumLineSpacing` for desired spacing between items

## How It Works

The `SnappingFlowLayout` overrides `targetContentOffset(forProposedContentOffset:withScrollingVelocity:)` to:

1. **Calculate the proposed center** of the visible area
2. **Search for nearby cells** within a configurable range
3. **Find the closest cell** to the proposed center
4. **Apply velocity-based logic** to determine if the user intended to move to the next/previous item
5. **Return the optimal offset** that centers the target cell

The algorithm considers both the current scroll position and the user's scroll velocity to provide intuitive snapping behavior that feels natural and responsive.

## Requirements

- iOS 11.0+
- Xcode 12.0+
- Swift 5.0+

## License

This project is open source and available under the [MIT License](LICENSE).

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## Author

Created by [Kartiken Barnwal](https://github.com/kartikenbarnwal)

---

**Note**: This is a demo project showcasing the `SnappingFlowLayout` implementation. The usage is straightforward and can be understood by examining the `ViewController.swift` file, which demonstrates a complete working example.
