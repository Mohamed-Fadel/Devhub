import 'package:flutter/material.dart';
import '../../domain/entities/skill.dart';

class SkillsSection extends StatelessWidget {
  final List<Skill> skills;
  final Function(Skill)? onAddSkill;
  final Function(String)? onRemoveSkill;
  final Function(String, SkillLevel)? onUpdateLevel;
  final bool isEditable;

  const SkillsSection({
    super.key,
    required this.skills,
    this.onAddSkill,
    this.onRemoveSkill,
    this.onUpdateLevel,
    this.isEditable = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Skills',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (isEditable && onAddSkill != null)
                IconButton(
                  icon: const Icon(Icons.add_circle_outline),
                  onPressed: () => _showAddSkillDialog(context),
                ),
            ],
          ),
          const SizedBox(height: 12),
          if (skills.isEmpty)
            Center(
              child: Text(
                'No skills added yet',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 14,
                ),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: skills.map((skill) {
                return _SkillChip(
                  skill: skill,
                  onRemove: isEditable ? () => onRemoveSkill?.call(skill.id) : null,
                  onTap: isEditable && onUpdateLevel != null
                      ? () => _showUpdateLevelDialog(context, skill)
                      : null,
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  void _showAddSkillDialog(BuildContext context) {
    final nameController = TextEditingController();
    SkillLevel selectedLevel = SkillLevel.intermediate;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Skill'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Skill Name',
                hintText: 'e.g., Flutter, Dart, Firebase',
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<SkillLevel>(
              value: selectedLevel,
              decoration: const InputDecoration(labelText: 'Skill Level'),
              items: SkillLevel.values.map((level) {
                return DropdownMenuItem(
                  value: level,
                  child: Text(_getLevelText(level)),
                );
              }).toList(),
              onChanged: (level) => selectedLevel = level!,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (nameController.text.trim().isNotEmpty) {
                final skill = Skill(
                  id: DateTime.now().millisecondsSinceEpoch.toString(),
                  name: nameController.text.trim(),
                  level: selectedLevel,
                );
                onAddSkill!(skill);
                Navigator.of(context).pop();
              }
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  void _showUpdateLevelDialog(BuildContext context, Skill skill) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Update ${skill.name} Level'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: SkillLevel.values.map((level) {
            return RadioListTile<SkillLevel>(
              title: Text(_getLevelText(level)),
              value: level,
              groupValue: skill.level,
              onChanged: (newLevel) {
                if (newLevel != null) {
                  onUpdateLevel!(skill.id, newLevel);
                  Navigator.of(context).pop();
                }
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  String _getLevelText(SkillLevel level) {
    switch (level) {
      case SkillLevel.beginner:
        return 'Beginner';
      case SkillLevel.intermediate:
        return 'Intermediate';
      case SkillLevel.advanced:
        return 'Advanced';
      case SkillLevel.expert:
        return 'Expert';
    }
  }
}

class _SkillChip extends StatelessWidget {
  final Skill skill;
  final VoidCallback? onRemove;
  final VoidCallback? onTap;

  const _SkillChip({
    required this.skill,
    this.onRemove,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getColorForLevel(skill.level);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              skill.name,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (onRemove != null) ...[
              const SizedBox(width: 4),
              InkWell(
                onTap: onRemove,
                child: Icon(
                  Icons.close,
                  size: 14,
                  color: color,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Color _getColorForLevel(SkillLevel level) {
    switch (level) {
      case SkillLevel.beginner:
        return Colors.green;
      case SkillLevel.intermediate:
        return Colors.blue;
      case SkillLevel.advanced:
        return Colors.orange;
      case SkillLevel.expert:
        return Colors.purple;
    }
  }
}