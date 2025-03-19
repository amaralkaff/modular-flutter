import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../models/cart_item.dart';
import '../repositories/cart_repository.dart';

// Events
abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

class AddItemToCart extends CartEvent {
  final CartItem item;

  const AddItemToCart(this.item);

  @override
  List<Object?> get props => [item];
}

class RemoveItemFromCart extends CartEvent {
  final String itemId;

  const RemoveItemFromCart(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

class UpdateItemQuantity extends CartEvent {
  final String itemId;
  final int quantity;

  const UpdateItemQuantity(this.itemId, this.quantity);

  @override
  List<Object?> get props => [itemId, quantity];
}

class ClearCart extends CartEvent {}

// States
abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

class CartInitial extends CartState {}

class CartLoading extends CartState {}

class CartLoaded extends CartState {
  final List<CartItem> items;
  final double total;

  const CartLoaded({required this.items, required this.total});

  @override
  List<Object?> get props => [items, total];
}

class CartError extends CartState {
  final String message;

  const CartError(this.message);

  @override
  List<Object?> get props => [message];
}

// Bloc
class CartBloc extends Bloc<CartEvent, CartState> {
  final CartRepository _repository;

  CartBloc(this._repository) : super(CartInitial()) {
    on<AddItemToCart>(_onAddItemToCart);
    on<RemoveItemFromCart>(_onRemoveItemFromCart);
    on<UpdateItemQuantity>(_onUpdateItemQuantity);
    on<ClearCart>(_onClearCart);
  }

  Future<void> _onAddItemToCart(
    AddItemToCart event,
    Emitter<CartState> emit,
  ) async {
    try {
      emit(CartLoading());
      await _repository.addItem(event.item);
      final items = await _repository.getItems();
      final total = await _repository.getTotal();
      emit(CartLoaded(items: items, total: total));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onRemoveItemFromCart(
    RemoveItemFromCart event,
    Emitter<CartState> emit,
  ) async {
    try {
      emit(CartLoading());
      await _repository.removeItem(event.itemId);
      final items = await _repository.getItems();
      final total = await _repository.getTotal();
      emit(CartLoaded(items: items, total: total));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onUpdateItemQuantity(
    UpdateItemQuantity event,
    Emitter<CartState> emit,
  ) async {
    try {
      emit(CartLoading());
      await _repository.updateQuantity(event.itemId, event.quantity);
      final items = await _repository.getItems();
      final total = await _repository.getTotal();
      emit(CartLoaded(items: items, total: total));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }

  Future<void> _onClearCart(
    ClearCart event,
    Emitter<CartState> emit,
  ) async {
    try {
      emit(CartLoading());
      await _repository.clearCart();
      emit(const CartLoaded(items: [], total: 0));
    } catch (e) {
      emit(CartError(e.toString()));
    }
  }
} 