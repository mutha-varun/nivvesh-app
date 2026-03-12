import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nivvesh/webview/screens/bank_inappWebView.dart';
import 'package:nivvesh/webview/screens/support_webview.dart';
import 'package:pinput/pinput.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';
import 'api_service.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _startLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final phone = "+91${_phoneController.text}";
    final success = await ApiService.sendOtp(phone);

    setState(() => _isLoading = false);

    if (success) {
      _showOtpBottomSheet(phone);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to send OTP')),
      );
    }
  }

  void _showOtpBottomSheet(String phone) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFF1C1C1C),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => OTPBottomSheet(phoneNumber: phone),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xff1c1c1e),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Align(
                    alignment: Alignment.topRight,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushAndRemoveUntil(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const SupportWebView(
                                  url: 'https://nivvesh.fixerra.in/support',
                                  title: ''),
                            ),
                            (route) => route.isFirst);
                      },
                      child: Container(
                          margin: const EdgeInsets.only(top: 20),
                          height: 25,
                          width: 25,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(50),
                              border: Border.all(color: Colors.white)),
                          padding: const EdgeInsets.all(2),
                          child: const Center(
                              child: Icon(
                            Icons.live_help_outlined,
                            color: Colors.white,
                            size: 15,
                          ))),
                    )),
                const SizedBox(height: 40),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.asset(
                      'assets/nivvesh_logo.png',
                      height: 80,
                      fit: BoxFit.cover,
                    ),
                  ],
                ),
                const SizedBox(height: 60),
                const Text(
                  'GET STARTED',
                  style: TextStyle(
                    color: Color(0xffccccd5),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Begin your Investment\nJourney',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Please enter your Aadhaar Linked Mobile number\nfor verification',
                  style: TextStyle(color: Color(0xffccccd5), fontSize: 14),
                ),
                const SizedBox(height: 12),
                Form(
                  key: _formKey,
                  child: TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    maxLength: 10,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    style: const TextStyle(color: Colors.white),
                    validator: (value) {
                      if (value == null || value.length != 10) {
                        return 'Enter a valid 10 digit number';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: Colors.transparent,
                      prefixIcon: Container(
                        padding: const EdgeInsets.only(left: 12),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.phone_outlined,
                              color: Colors.grey,
                              size: 18,
                            ),
                            SizedBox(width: 4),
                            Text(
                              '+91 -',
                              style: TextStyle(
                                fontSize: 16,
                                color: Color(0xffccccd5),
                              ),
                            ),
                          ],
                        ),
                      ),
                      hintText: '10 Digit Number',
                      hintStyle: const TextStyle(color: Colors.white),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.white),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Colors.grey),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? () {} : _startLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFf8ec80),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.black,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Get Started',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class OTPBottomSheet extends StatefulWidget {
  final String phoneNumber;
  const OTPBottomSheet({super.key, required this.phoneNumber});

  @override
  State<OTPBottomSheet> createState() => _OTPBottomSheetState();
}

class _OTPBottomSheetState extends State<OTPBottomSheet> {
  final TextEditingController _otpController = TextEditingController();
  bool _isSubmitting = false;
  int _resendSeconds = 60;
  Timer? _timer;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    setState(() {
      _resendSeconds = 60;
      _canResend = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds == 0) {
        setState(() => _canResend = true);
        timer.cancel();
      } else {
        setState(() => _resendSeconds--);
      }
    });
  }

  void _resendOtp() async {
    final success = await ApiService.sendOtp(widget.phoneNumber);
    if (success) {
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.success(message: 'OTP resent successfully!'),
      );
      _startTimer(); // restart countdown
    } else {
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.error(message: 'Failed to resend OTP'),
      );
    }
  }

  void _submitOtp() async {
    if (_otpController.text.length != 6) {
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.error(message: 'Enter a valid 6-digit OTP'),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    final result =
        await ApiService.verifyOtp(widget.phoneNumber, _otpController.text);

    setState(() => _isSubmitting = false);

    if (result != null) {
      Navigator.of(context).pop();
      // showTopSnackBar(
      //   Overlay.of(context),
      //   CustomSnackBar.success(message: result.message),
      // );
      if (result.redirectUrl.isNotEmpty) {
        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
              builder: (_) =>
                  InAppWebViewScreen(url: result.redirectUrl, title: ''),
            ),
            (route) => false);
      }
    } else {
      showTopSnackBar(
        Overlay.of(context),
        const CustomSnackBar.error(message: 'OTP Verification Failed'),
      );
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedPadding(
      padding: MediaQuery.of(context).viewInsets,
      duration: const Duration(milliseconds: 100),
      curve: Curves.decelerate,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.phone_outlined, color: Colors.grey, size: 18),
                const SizedBox(width: 8),
                const Text('VERIFY MOBILE NUMBER',
                    style: TextStyle(color: Color(0xffccccd5))),
                const Spacer(),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    height: 20,
                    width: 20,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.grey),
                    child: const Center(
                        child: Icon(Icons.close,
                            color: Color(0xffccccd5), size: 15)),
                  ),
                )
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Please enter the verification code',
              style: TextStyle(color: Color(0xffccccd5)),
            ),
            Text(
              widget.phoneNumber,
              style: const TextStyle(color: Colors.white),
            ),
            const SizedBox(height: 24),
            Pinput(
              controller: _otpController,
              length: 6,
              defaultPinTheme: PinTheme(
                width: 45,
                height: 55,
                textStyle: const TextStyle(fontSize: 20, color: Colors.white),
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey),
                ),
              ),
              focusedPinTheme: PinTheme(
                width: 45,
                height: 55,
                textStyle: const TextStyle(fontSize: 20, color: Colors.white),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.white),
                ),
              ),
              keyboardType: TextInputType.number,
              cursor: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    width: 22,
                    height: 1,
                    color: Colors.white,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            LinearProgressIndicator(
              value: (_resendSeconds / 60),
              color: Colors.greenAccent,
              backgroundColor: Colors.grey.shade800,
            ),
            const SizedBox(height: 12),
            _resendSeconds > 0
                ? Text(
                    'Resend Code in 00:${_resendSeconds.toString().padLeft(2, '0')}',
                    style: const TextStyle(color: Colors.white),
                  )
                : TextButton(
                    onPressed: _resendOtp,
                    child: const Text(
                      'Resend OTP',
                      style: TextStyle(color: Color(0xffccccd5)),
                    ),
                  ),

            // Text(
            //   'Resend Code in 00:${_resendSeconds.toString().padLeft(2, '0')}',
            //   style: const TextStyle(color: Colors.white),
            // ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSubmitting ? () {} : _submitOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFf8ec80),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.black,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Submit'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
