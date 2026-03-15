import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controller/progress_controller.dart';

class UpdateProgreesScreenView extends StatefulWidget {
  const UpdateProgreesScreenView({super.key});

  @override
  State<UpdateProgreesScreenView> createState() => _UpdateProgreesScreenViewState();
}

class _UpdateProgreesScreenViewState extends State<UpdateProgreesScreenView> {
  final ProgressController _progressController = Get.find<ProgressController>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();
  double _progressValue = 30;

  @override
  void initState() {
    super.initState();
    _nameController.text = 'Foundation Completed';
    _noteController.text = 'Foundation and base slab completed';
  }

  Future<void> _submitProgress() async {
    final String progressName = _nameController.text.trim();
    final String note = _noteController.text.trim();
    final int percent = _progressValue.round();

    if (progressName.isEmpty) {
      Get.snackbar('Validation', 'Please enter progress name');
      return;
    }

    if (note.isEmpty) {
      Get.snackbar('Validation', 'Please enter note');
      return;
    }

    final bool success = await _progressController.submitProgress(
      progressName: progressName,
      percent: percent,
      note: note,
    );

    if (!mounted) return;
    if (success) {
      Get.snackbar('Success', 'Progress submitted');
      Navigator.of(context).maybePop();
    } else {
      Get.snackbar(
        'Error',
        _progressController.submitErrorMessage.value,
      );
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color bgColor = Color(0xFF061118);
    const Color fieldBorderColor = Color(0xFFE6E6E6);
    const Color cardColor = Color(0xFF152128);
    const Color textColor = Color(0xFFF2F2F2);
    const Color hintColor = Color(0xB3D0D0D0);
    const Color sliderThumbColor = Color(0xFFC59A69);
    const Color sliderTrackColor = Color(0xFFE7E3DB);

    return Scaffold(
      backgroundColor: bgColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text(
                'Name of the progress',
                style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w400, height: 1.1),
              ),
              const SizedBox(height: 14),
              TextField(
                controller: _nameController,
                style: const TextStyle(color: textColor, fontSize: 18),
                decoration: InputDecoration(
                  hintText: 'Enter the progress name',
                  hintStyle: const TextStyle(color: hintColor, fontSize: 16),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: fieldBorderColor, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: fieldBorderColor, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: fieldBorderColor, width: 1.2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _noteController,
                maxLines: 2,
                style: const TextStyle(color: textColor, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'Enter note',
                  hintStyle: const TextStyle(color: hintColor, fontSize: 15),
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: fieldBorderColor, width: 1),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: fieldBorderColor, width: 1),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: fieldBorderColor, width: 1.2),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text('Current: ${_progressValue.toStringAsFixed(0)}%', style: const TextStyle(color: textColor, fontSize: 16)),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(color: cardColor, borderRadius: BorderRadius.circular(16)),
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 8,
                    activeTrackColor: sliderTrackColor,
                    inactiveTrackColor: sliderTrackColor.withValues(alpha: 0.3),
                    thumbColor: sliderThumbColor,
                    overlayColor: sliderThumbColor.withValues(alpha: 0.2),
                    thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                  ),
                  child: Slider(
                    value: _progressValue,
                    min: 0,
                    max: 100,
                    onChanged: (value) {
                      setState(() {
                        _progressValue = value;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 50,
                width: double.infinity,
                child: Obx(
                  () {
                    final bool isSubmitting = _progressController.isSubmitting.value;
                    return ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: sliderThumbColor,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      onPressed: isSubmitting ? null : _submitProgress,
                      child: isSubmitting
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Submit Progress',
                              style: TextStyle(color: textColor, fontSize: 16, fontWeight: FontWeight.w500),
                            ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
