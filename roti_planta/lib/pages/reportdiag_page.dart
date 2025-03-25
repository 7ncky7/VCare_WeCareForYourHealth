import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:roti_planta/appconfig.dart';
import 'package:roti_planta/pages/aichat_page.dart';
import 'package:roti_planta/pages/application_page.dart';

class ReportDiagPage extends StatefulWidget {
  const ReportDiagPage({super.key});

  @override
  _ReportDiagPageState createState() => _ReportDiagPageState();
}

class _ReportDiagPageState extends State<ReportDiagPage> {
  File? _selectedFile;
  String? _aiDiagnosis;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _pickFile() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFile = File(result.files.single.path!);
          _aiDiagnosis = null;
          _errorMessage = null;
        });

        // Automatically upload after picking the file
        await _uploadAndGenerateDiagnosis();
      } else {
        setState(() {
          _errorMessage = 'No file selected.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error picking file: $e';
      });
    }
  }

  Future<void> _uploadAndGenerateDiagnosis() async {
    if (_selectedFile == null) {
      setState(() {
        _errorMessage = 'No file selected for upload.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Use AppConfig.baseUrl to construct the backend URL
      final url = Uri.parse('${AppConfig.baseUrl}/api/process-document');
      var request = http.MultipartRequest('POST', url);

      // Attach the PDF file to the request
      request.files.add(
        await http.MultipartFile.fromPath(
          'file', // The key expected by the Flask backend
          _selectedFile!.path,
          filename: _selectedFile!.path.split('/').last,
        ),
      );

      // Send the request to the Flask backend
      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        setState(() {
          _aiDiagnosis = data['result'] ?? 'No analysis received from AI.';
          _isLoading = false;
        });
      } else {
        final data = jsonDecode(responseBody);
        setState(() {
          _errorMessage = data['error'] ?? 'Failed to get diagnosis: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF852745)),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const ApplicationPage()),
            );
          },
        ),
        backgroundColor: const Color(0xFFD59FA6),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFD59FA6), Colors.white],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(top: 0, right: 15, bottom: 10, left: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Title, Description, and Report Icon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/healthboard_icon.png',
                          height: 135,
                          color: const Color(0xFF852745),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(left: 0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  localizations?.reportDiagnosis ?? 'Report Diagnosis',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineLarge
                                      ?.copyWith(
                                        color: const Color(0xFF852745),
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  localizations?.uploadMedicalReports ??
                                      'Upload your medical reports and I will generate a detailed explanation for you.',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodyMedium
                                      ?.copyWith(
                                        color: Colors.black54,
                                      ),
                                  textAlign: TextAlign.start,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),

                    // 2. Peach Box with Diagnosis Section
                    Card(
                      elevation: 7.0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                      ),
                      color: const Color(0xFFFFE5D9),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 20, right: 20, bottom: 15, left: 20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Diagnosis Title with Underline
                            Center(
                              child: Text(
                                localizations?.diagnosis ?? 'AI Diagnosis',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF852745),
                                  decoration: TextDecoration.underline,
                                  decorationColor: Color(0xFF852745),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),

                            // 3. White Box for Upload or AI-Generated Text
                            GestureDetector(
                              onTap: _isLoading ? null : _pickFile,
                              child: Container(
                                width: double.infinity,
                                height: 480,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.3),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                    ),
                                  ],
                                  border: Border.all(
                                    color: const Color.fromARGB(255, 119, 26, 26),
                                    width: 1.5,
                                  ),
                                ),
                                child: _isLoading
                                    ? const Center(
                                        child: CircularProgressIndicator(),
                                      )
                                    : _errorMessage != null
                                        ? Center(
                                            child: Text(
                                              _errorMessage!,
                                              style: const TextStyle(
                                                color: Colors.red,
                                                fontSize: 16,
                                              ),
                                              textAlign: TextAlign.center,
                                            ),
                                          )
                                        : _aiDiagnosis != null
                                            ? SingleChildScrollView(
                                                padding: const EdgeInsets.all(10.0),
                                                child: Text(
                                                  _aiDiagnosis!,
                                                  style: const TextStyle(
                                                    color: Colors.black87,
                                                    fontSize: 16,
                                                  ),
                                                ),
                                              )
                                            : _selectedFile != null
                                                ? Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      const Icon(
                                                        Icons.description,
                                                        size: 50,
                                                        color: Color(0xFF852745),
                                                      ),
                                                      const SizedBox(height: 10),
                                                      Text(
                                                        'Selected File: ${_selectedFile!.path.split('/').last}',
                                                        style: const TextStyle(
                                                          color: Colors.black87,
                                                          fontSize: 16,
                                                          fontWeight: FontWeight.bold,
                                                        ),
                                                        textAlign: TextAlign.center,
                                                      ),
                                                      const SizedBox(height: 10),
                                                      const Text(
                                                        'Uploading...',
                                                        style: TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 14,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      const Icon(
                                                        Icons.upload_file,
                                                        size: 80,
                                                        color: Color(0xFF852745),
                                                      ),
                                                      const SizedBox(height: 10),
                                                      Text(
                                                        localizations?.dropYourReport ??
                                                            'Drop your report (.pdf) here',
                                                        style: const TextStyle(
                                                          color: Colors.grey,
                                                          fontSize: 16,
                                                        ),
                                                      ),
                                                      const SizedBox(height: 10),
                                                      ElevatedButton.icon(
                                                        onPressed: _pickFile,
                                                        icon: const Icon(Icons.upload, size: 25),
                                                        label: Text(
                                                          localizations?.uploadFile ?? 'Upload File',
                                                        ),
                                                        style: ElevatedButton.styleFrom(
                                                          backgroundColor: const Color(0xFF852745),
                                                          foregroundColor: Colors.white,
                                                          padding: const EdgeInsets.symmetric(
                                                            horizontal: 35,
                                                            vertical: 12,
                                                          ),
                                                          shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(10),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}