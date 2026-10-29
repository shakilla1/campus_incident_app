import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../models/incident.dart';
import '../providers/auth_provider.dart';
import '../providers/incident_provider.dart';
import '../utils/constants.dart';
import '../utils/validators.dart';
import '../widgets/primary_button.dart';

class ReportFormScreen extends StatefulWidget {
  final Incident? editing;

  const ReportFormScreen({super.key, this.editing});

  @override
  State<ReportFormScreen> createState() => _ReportFormScreenState();
}

class _ReportFormScreenState extends State<ReportFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final _title = TextEditingController(text: widget.editing?.title);
  late final _description = TextEditingController(text: widget.editing?.description);
  late final _location = TextEditingController(text: widget.editing?.location);
  late String? _category = widget.editing?.category;
  File? _photo;
  bool _saving = false;
  bool _categoryMissing = false;

  bool get _isEditing => widget.editing != null;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    _location.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto(ImageSource source) async {
    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 50,
      maxWidth: 800,
    );
    if (picked != null) setState(() => _photo = File(picked.path));
  }

  void _choosePhotoSource() {
    showModalBottomSheet(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Take a photo'),
              onTap: () {
                Navigator.pop(sheetContext);
                _pickPhoto(ImageSource.camera);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () {
                Navigator.pop(sheetContext);
                _pickPhoto(ImageSource.gallery);
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _submit() async {
    final valid = _formKey.currentState!.validate();
    setState(() => _categoryMissing = _category == null);
    if (!valid || _category == null) return;

    final incidents = context.read<IncidentProvider>();
    final user = context.read<AuthProvider>().user!;
    final messenger = ScaffoldMessenger.of(context);
    setState(() => _saving = true);

    final error = _isEditing
        ? await incidents.edit(
            widget.editing!.id,
            title: _title.text.trim(),
            description: _description.text.trim(),
            category: _category!,
            location: _location.text.trim(),
          )
        : await incidents.submit(
            user: user,
            title: _title.text.trim(),
            description: _description.text.trim(),
            category: _category!,
            location: _location.text.trim(),
            photo: _photo,
          );

    if (!mounted) return;
    setState(() => _saving = false);
    if (error != null) {
      messenger.showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    Navigator.pop(context);
    messenger.showSnackBar(
      SnackBar(content: Text(_isEditing ? 'Report updated.' : 'Report submitted.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEditing ? 'Edit report' : 'Report an incident')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              const Text('Select a category', style: TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories.map((c) {
                  return ChoiceChip(
                    avatar: Icon(categoryIcons[c], size: 18),
                    label: Text(c),
                    selected: _category == c,
                    onSelected: (_) => setState(() {
                      _category = c;
                      _categoryMissing = false;
                    }),
                  );
                }).toList(),
              ),
              if (_categoryMissing)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text(
                    'Pick a category',
                    style: TextStyle(color: Theme.of(context).colorScheme.error, fontSize: 12),
                  ),
                ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _title,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  hintText: 'Briefly describe the issue',
                ),
                validator: (v) => requiredField(v, 'Title', minLength: 3),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _description,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'What happened, when, and who is affected',
                  alignLabelWithHint: true,
                ),
                validator: (v) => requiredField(v, 'Description', minLength: 10),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _location,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  hintText: 'e.g. Block B, Room 204',
                  prefixIcon: Icon(Icons.location_on_outlined),
                ),
                validator: (v) => requiredField(v, 'Location'),
              ),
              if (!_isEditing) ...[
                const SizedBox(height: 20),
                _PhotoPicker(
                  photo: _photo,
                  onPick: _choosePhotoSource,
                  onRemove: () => setState(() => _photo = null),
                ),
              ],
              const SizedBox(height: 28),
              PrimaryButton(
                label: _isEditing ? 'Save changes' : 'Submit report',
                loading: _saving,
                onPressed: _submit,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PhotoPicker extends StatelessWidget {
  final File? photo;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  const _PhotoPicker({required this.photo, required this.onPick, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    if (photo == null) {
      return OutlinedButton.icon(
        onPressed: onPick,
        icon: const Icon(Icons.add_a_photo_outlined),
        label: const Text('Add a photo (optional)'),
        style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
      );
    }
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.file(
            photo!,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: CircleAvatar(
            backgroundColor: Colors.black54,
            child: IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.close, color: Colors.white),
            ),
          ),
        ),
      ],
    );
  }
}
