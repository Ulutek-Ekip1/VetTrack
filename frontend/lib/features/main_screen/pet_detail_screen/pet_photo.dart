import 'package:flutter/material.dart';

import '../../pet/domain/entities/pet_entity.dart';

class PetPhoto extends StatelessWidget {
  const PetPhoto({
    super.key,
    required this.pet,
  });

  final PetEntity? pet;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 10,
            spreadRadius: 2,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: CircleAvatar(
        radius: MediaQuery.of(context).size.width * 0.12,
        backgroundColor: Theme.of(context).colorScheme.surface,
        backgroundImage:
            pet?.photoUrl != null ? NetworkImage(pet!.photoUrl!) : null,
        child: pet?.photoUrl == null
            ? Icon(Icons.pets,
                color: Theme.of(context).colorScheme.primary,
                size: MediaQuery.of(context).size.width * 0.10)
            : null,
      ),
    );
  }
}
