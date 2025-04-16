import 'package:flutter/material.dart';
import 'package:resturent/models/menu_item.dart';
import 'package:resturent/models/cart_item.dart';
import 'package:resturent/features/cart/cart_provider.dart';
import 'package:provider/provider.dart';

class MenuItemDetailsScreen extends StatefulWidget {
  final MenuItem item;

  const MenuItemDetailsScreen({
    super.key,
    required this.item,
  });

  @override
  State<MenuItemDetailsScreen> createState() => _MenuItemDetailsScreenState();
}

class _MenuItemDetailsScreenState extends State<MenuItemDetailsScreen> {
  int _quantity = 1;
  String? _selectedSize;
  List<String> _selectedExtras = [];

  @override
  void initState() {
    super.initState();
    if (widget.item.size?.isNotEmpty ?? false) {
      _selectedSize = widget.item.size?.first;
    }
  }

  double get _totalPrice {
    double basePrice = widget.item.discountPrice ?? widget.item.price;
    if (_selectedSize != null) {
      basePrice += widget.item.sizePrices[_selectedSize] ?? 0;
    }
    double extrasPrice = _selectedExtras.fold(
      0,
      (sum, extra) => sum + (widget.item.extraPrices[extra] ?? 0),
    );
    return (basePrice + extrasPrice) * _quantity;
  }

  void _addToCart() {
    final cartItem = CartItem(
      menuItem: widget.item,
      quantity: _quantity,
      selectedSize: _selectedSize,
      selectedExtras: _selectedExtras,
      totalPrice: _totalPrice,
    );

    context.read<CartProvider>().addItem(cartItem);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Added to cart'),
        duration: Duration(seconds: 2),
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'menu_item_${widget.item.id}',
                child: Image.network(
                  widget.item.imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          widget.item.name,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      ),
                      if (widget.item.isVegetarian)
                        Tooltip(
                          message: 'Vegetarian',
                          child: Icon(Icons.eco, color: Colors.green[700]),
                        ),
                      if (widget.item.isSpicy)
                        Tooltip(
                          message: 'Spicy',
                          child: Icon(Icons.whatshot, color: Colors.red[700]),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (widget.item.discountPrice != null) ...[
                        Text(
                          '\$${widget.item.price.toStringAsFixed(2)}',
                          style: TextStyle(
                            decoration: TextDecoration.lineThrough,
                            color: Theme.of(context).textTheme.bodySmall?.color,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '\$${widget.item.discountPrice!.toStringAsFixed(2)}',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ] else
                        Text(
                          '\$${widget.item.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      if (widget.item.rating > 0) ...[
                        const Spacer(),
                        Icon(Icons.star, color: Colors.amber[700]),
                        const SizedBox(width: 4),
                        Text(
                          widget.item.rating.toStringAsFixed(1),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.item.description,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                  if (widget.item.size?.isNotEmpty ?? false) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Size',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Wrap(
                      spacing: 8,
                      children: widget.item.size?.map((size) {
                            return ChoiceChip(
                              label: Text(size),
                              selected: _selectedSize == size,
                              onSelected: (selected) {
                                setState(() {
                                  _selectedSize = selected ? size : null;
                                });
                              },
                            );
                          }).toList() ??
                          [],
                    ),
                  ],
                  if (widget.item.extras.isNotEmpty) ...[
                    const SizedBox(height: 16),
                    Text(
                      'Extras',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Wrap(
                      spacing: 8,
                      children: widget.item.extras.map((extra) {
                        return FilterChip(
                          label: Text(
                              '$extra (+\$${widget.item.extraPrices[extra]?.toStringAsFixed(2)})'),
                          selected: _selectedExtras.contains(extra),
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedExtras.add(extra);
                              } else {
                                _selectedExtras.remove(extra);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      IconButton(
                        onPressed: _quantity > 1
                            ? () => setState(() => _quantity--)
                            : null,
                        icon: const Icon(Icons.remove),
                      ),
                      Text(
                        _quantity.toString(),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      IconButton(
                        onPressed: () => setState(() => _quantity++),
                        icon: const Icon(Icons.add),
                      ),
                      const Spacer(),
                      Text(
                        'Total: \$${_totalPrice.toStringAsFixed(2)}',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ElevatedButton(
            onPressed: _addToCart,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text(
              'Add to Cart',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }
}
