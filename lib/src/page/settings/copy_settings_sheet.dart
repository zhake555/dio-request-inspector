import 'package:dio_request_inspector/src/common/copy_settings_storage.dart';
import 'package:dio_request_inspector/src/model/copy_settings.dart';
import 'package:dio_request_inspector/src/page/resources/app_color.dart';
import 'package:flutter/material.dart';

class CopySettingsSheet extends StatefulWidget {
  const CopySettingsSheet({Key? key}) : super(key: key);

  @override
  State<CopySettingsSheet> createState() => _CopySettingsSheetState();
}

class _CopySettingsSheetState extends State<CopySettingsSheet> {
  late CopySettings _settings;
  final _headerController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _settings = CopySettingsStorage.current;
    CopySettingsStorage.load().then((_) {
      if (mounted) {
        setState(() {
          _settings = CopySettingsStorage.current;
        });
      }
    });
  }

  @override
  void dispose() {
    _headerController.dispose();
    super.dispose();
  }

  void _update(CopySettings updated) {
    setState(() => _settings = updated);
    CopySettingsStorage.save(updated);
  }

  void _addHeader() {
    final value = _headerController.text.trim().toLowerCase();
    if (value.isEmpty || _settings.excludedHeaders.contains(value)) return;
    _update(_settings.copyWith(
      excludedHeaders: [..._settings.excludedHeaders, value],
    ));
    _headerController.clear();
  }

  void _removeHeader(String header) {
    _update(_settings.copyWith(
      excludedHeaders: [..._settings.excludedHeaders]..remove(header),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Copy Settings',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColor.primary,
              ),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Include request headers'),
              value: _settings.copyRequestHeaders,
              activeThumbColor: AppColor.primary,
              onChanged: (v) =>
                  _update(_settings.copyWith(copyRequestHeaders: v)),
            ),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Include response headers'),
              value: _settings.copyResponseHeaders,
              activeThumbColor: AppColor.primary,
              onChanged: (v) =>
                  _update(_settings.copyWith(copyResponseHeaders: v)),
            ),
            const Divider(height: 24),
            Text(
              'Excluded headers',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            if (_settings.excludedHeaders.isEmpty)
              Text(
                'No excluded headers',
                style: TextStyle(color: Colors.grey[500], fontSize: 13),
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _settings.excludedHeaders
                    .map(
                      (h) => Chip(
                        label: Text(h),
                        deleteIcon: const Icon(Icons.close, size: 16),
                        onDeleted: () => _removeHeader(h),
                        backgroundColor:
                            AppColor.primary.withValues(alpha: 0.1),
                        labelStyle: TextStyle(color: AppColor.primary),
                        deleteIconColor: AppColor.primary,
                      ),
                    )
                    .toList(),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _headerController,
                    decoration: InputDecoration(
                      hintText: 'Add header (e.g. x-api-key)',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: AppColor.primary),
                      ),
                    ),
                    onSubmitted: (_) => _addHeader(),
                    textInputAction: TextInputAction.done,
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: _addHeader,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.primary,
                    foregroundColor: AppColor.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  child: const Text('Add'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
