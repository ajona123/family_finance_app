import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../data/models/arisan.dart';
import '../../../data/providers/arisan_provider.dart';
import '../../../data/providers/member_provider.dart';

class CreateArisanDialog extends StatefulWidget {
  const CreateArisanDialog({super.key});

  @override
  State<CreateArisanDialog> createState() => _CreateArisanDialogState();
}

class _CreateArisanDialogState extends State<CreateArisanDialog> {
  late TextEditingController _nameController;
  late TextEditingController _amountController;
  late TextEditingController _cycleController;
  DateTime _selectedStartDate = DateTime.now();
  Set<String> _selectedParticipants = {};
  String? _selectedOrganizerError;
  String? _nameError;
  String? _amountError;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _amountController = TextEditingController();
    _cycleController = TextEditingController(text: '3');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _amountController.dispose();
    _cycleController.dispose();
    super.dispose();
  }

  void _validateAndCreate() {
    setState(() {
      _nameError = null;
      _amountError = null;
      _selectedOrganizerError = null;
    });

    bool isValid = true;

    if (_nameController.text.trim().isEmpty) {
      setState(() => _nameError = 'Nama arisan tidak boleh kosong');
      isValid = false;
    }

    if (_amountController.text.trim().isEmpty) {
      setState(() => _amountError = 'Jumlah setoran tidak boleh kosong');
      isValid = false;
    } else {
      try {
        int.parse(_amountController.text.replaceAll('.', ''));
      } catch (e) {
        setState(() => _amountError = 'Format angka tidak valid');
        isValid = false;
      }
    }

    if (_selectedParticipants.isEmpty) {
      setState(() => _selectedOrganizerError = 'Pilih minimal 1 peserta');
      isValid = false;
    }

    if (!isValid) return;

    final arisanProvider = context.read<ArisanProvider>();
    final memberProvider = context.read<MemberProvider>();
    final currentMemberId = memberProvider.selectedMember?.id ?? 'unknown';

    final arisan = Arisan(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: _nameController.text.trim(),
      memberId: currentMemberId,
      startDate: _selectedStartDate,
      cycleLengthMonths: int.parse(_cycleController.text),
      monthlyAmount: double.parse(_amountController.text.replaceAll('.', '')),
      participantMemberIds: _selectedParticipants.toList(),
      userPosition: _selectedParticipants.toList().indexOf(currentMemberId) + 1,
      paymentHistory: [],
      status: 'active',
      createdAt: DateTime.now(),
    );

    arisanProvider.addArisan(arisan);
    Navigator.pop(context);
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Arisan berhasil dibuat!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.radiusL),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.spacingL),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // HEADER
              Text(
                'Buat Arisan Baru',
                style: AppTypography.headingSmall.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: AppConstants.spacingL),

              // NAMA ARISAN
              Text(
                'Nama Arisan',
                style: AppTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppConstants.spacingS),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  hintText: 'Contoh: Arisan Keluarga',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  ),
                  errorText: _nameError,
                ),
              ),
              const SizedBox(height: AppConstants.spacingL),

              // JUMLAH SETORAN
              Text(
                'Jumlah Per Bulan (Rp)',
                style: AppTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppConstants.spacingS),
              TextField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Contoh: 300000',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  ),
                  errorText: _amountError,
                ),
                onChanged: (value) {
                  // Format with dots
                  if (value.isNotEmpty) {
                    final unformatted = value.replaceAll('.', '');
                    final formatted = CurrencyFormatter.formatInput(unformatted);
                    _amountController.value = TextEditingValue(
                      text: formatted,
                      selection: TextSelection.collapsed(offset: formatted.length),
                    );
                  }
                },
              ),
              const SizedBox(height: AppConstants.spacingL),

              // TANGGAL MULAI
              Text(
                'Tanggal Mulai',
                style: AppTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppConstants.spacingS),
              GestureDetector(
                onTap: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _selectedStartDate,
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(const Duration(days: 365)),
                  );
                  if (pickedDate != null) {
                    setState(() => _selectedStartDate = pickedDate);
                  }
                },
                child: Container(
                  padding: const EdgeInsets.all(AppConstants.spacingM),
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.border),
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${_selectedStartDate.day}/${_selectedStartDate.month}/${_selectedStartDate.year}',
                        style: AppTypography.bodyMedium,
                      ),
                      const Icon(Icons.calendar_today_outlined),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spacingL),

              // DURASI SIKLUS
              Text(
                'Durasi Siklus (Bulan)',
                style: AppTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: AppConstants.spacingS),
              TextField(
                controller: _cycleController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Contoh: 3, 6, 12',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  ),
                ),
              ),
              const SizedBox(height: AppConstants.spacingL),

              // PESERTA
              Text(
                'Pilih Peserta (${_selectedParticipants.length})',
                style: AppTypography.labelMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (_selectedOrganizerError != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppConstants.spacingS),
                  child: Text(
                    _selectedOrganizerError!,
                    style: AppTypography.bodySmall.copyWith(
                      color: AppColors.error,
                    ),
                  ),
                ),
              const SizedBox(height: AppConstants.spacingS),
              Consumer<MemberProvider>(
                builder: (context, memberProvider, _) {
                  final members = memberProvider.members;
                  return Container(
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: _selectedOrganizerError != null
                            ? AppColors.error
                            : AppColors.border,
                      ),
                      borderRadius: BorderRadius.circular(AppConstants.radiusM),
                    ),
                    child: ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: members.length,
                      itemBuilder: (context, index) {
                        final member = members[index];
                        final isSelected = _selectedParticipants.contains(member.id);
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppConstants.spacingM,
                            vertical: AppConstants.spacingS,
                          ),
                          child: Row(
                            children: [
                              Checkbox(
                                value: isSelected,
                                onChanged: (value) {
                                  setState(() {
                                    if (value == true) {
                                      _selectedParticipants.add(member.id);
                                    } else {
                                      _selectedParticipants.remove(member.id);
                                    }
                                  });
                                },
                              ),
                              Text(member.name),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
              const SizedBox(height: AppConstants.spacingXL),

              // BUTTONS
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Batal'),
                    ),
                  ),
                  const SizedBox(width: AppConstants.spacingM),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _validateAndCreate,
                      child: const Text('Buat Arisan'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
