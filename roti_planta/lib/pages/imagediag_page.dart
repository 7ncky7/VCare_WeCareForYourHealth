import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:file_picker/file_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:roti_planta/appconfig.dart';
import 'package:roti_planta/pages/application_page.dart';

class ImageDiagPage extends StatefulWidget {
  const ImageDiagPage({super.key});

  @override
  _ImageDiagPageState createState() => _ImageDiagPageState();
}

class _ImageDiagPageState extends State<ImageDiagPage> {
  File? _selectedImage;
  String? _aiDiagnosis;
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['png', 'jpg', 'jpeg'],
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedImage = File(result.files.single.path!);
          _aiDiagnosis = null; // Reset previous diagnosis
          _errorMessage = null; // Reset error message
          _isLoading = false; // Ensure loading state is reset
        });

        // Automatically call the API after image selection
        _uploadAndGenerateDiagnosis();
      } else {
        setState(() {
          _errorMessage = 'No image selected.';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Error picking image: $e';
      });
    }
  }

  Future<void> _uploadAndGenerateDiagnosis() async {
    if (_selectedImage == null) {
      setState(() {
        _errorMessage = 'No image selected.';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${AppConfig.baseUrl}/api/process-photo'), // Updated to match the REST API endpoint
      );

      // Attach the image to the request
      request.files.add(
        await http.MultipartFile.fromPath(
          'file', // Updated to match the field name expected by the API
          _selectedImage!.path,
          filename: _selectedImage!.path.split('/').last,
        ),
      );

      var response = await request.send();
      var responseBody = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = jsonDecode(responseBody);
        setState(() {
          _aiDiagnosis = data['result'] ?? 'No result received'; // Updated to match the API response field
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'Failed to get result: ${response.statusCode} - $responseBody';
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

  Future<bool> checkHealth() async {
    try {
      final response = await http.get(Uri.parse('${AppConfig.baseUrl}/api/health'));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  @override
  void initState() {
    super.initState();
    // Check server health when page loads
    checkHealth().then((isHealthy) {
      if (!isHealthy) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Warning: Unable to connect to server')),
        );
      }
    });
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
                      // 1. Title, Description, and Image Icon
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            'assets/images/imagediag_icon.png',
                            height: 130,
                            color: const Color(0xFF852745),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    localizations?.imageDiagnosis ?? 'Image Diagnosis',
                                    style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                          color: const Color(0xFF852745),
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    localizations?.uploadImageDescription ??
                                        'Upload your Ultrasound/X-Ray/CT Scan/MRI image here and I will generate a detailed explanation for you.',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                                onTap: _isLoading ? null : _pickImage, // Disable tap during loading
                                child: Container(
                                  width: double.infinity,
                                  height: 465,
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
                                              child: Padding(
                                                padding: const EdgeInsets.all(10.0),
                                                child: Text(
                                                  _errorMessage!,
                                                  style: const TextStyle(
                                                    color: Colors.red,
                                                    fontSize: 16,
                                                  ),
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            )
                                          : _aiDiagnosis != null
                                              ? SingleChildScrollView(
                                                  padding: const EdgeInsets.all(15.0),
                                                  child: Column(
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: _buildDiagnosisText(_aiDiagnosis!),
                                                  ),
                                                )
                                              : _selectedImage != null
                                                  ? Column(
                                                      mainAxisAlignment: MainAxisAlignment.center,
                                                      children: [
                                                        Image.file(
                                                          _selectedImage!,
                                                          height: 200,
                                                          fit: BoxFit.contain,
                                                          errorBuilder: (context, error, stackTrace) {
                                                            return const Icon(
                                                              Icons.broken_image,
                                                              size: 50,
                                                              color: Color(0xFF852745),
                                                            );
                                                          },
                                                        ),
                                                        const SizedBox(height: 10),
                                                        Text(
                                                          'Selected Image: ${_selectedImage!.path.split('/').last}',
                                                          style: const TextStyle(
                                                            color: Colors.black87,
                                                            fontSize: 16,
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                          textAlign: TextAlign.center,
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
                                                          localizations?.dropYourImage ??
                                                              'Drop your image (.png/.jpg/.jpeg) here',
                                                          style: const TextStyle(
                                                            color: Colors.grey,
                                                            fontSize: 16,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 10),
                                                        ElevatedButton.icon(
                                                          onPressed: _isLoading ? null : _pickImage,
                                                          icon: const Icon(Icons.upload, size: 25),
                                                          label: Text(
                                                            localizations?.uploadImage ?? 'Upload Image',
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

  // Helper method to build styled diagnosis text
  List<Widget> _buildDiagnosisText(String diagnosis) {
    List<Widget> widgets = [];
    List<String> sections = diagnosis.split('\n\n'); // Split by double newlines

    for (String section in sections) {
      List<String> lines = section.split('\n');
      if (lines.isEmpty) continue;

      // First line is the section header
      String header = lines[0];
      widgets.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            header,
            style: const TextStyle(
              fontSize: 18,
              //fontWeight: FontWeight.bold,  //bold text
              color: Color(0xFF852745),
            ),
          ),
        ),
      );

      // Remaining lines are body text or bullet points
      for (int i = 1; i < lines.length; i++) {
        String line = lines[i].trim();
        if (line.isEmpty) continue;

        if (line.startsWith('•')) {
          // Bullet point
          widgets.add(
            Padding(
              padding: const EdgeInsets.only(left: 10.0, bottom: 4.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '•',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      line.substring(1).trim(), // Remove the bullet point for the text
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          // Regular body text
          widgets.add(
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Text(
                line,
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.black87,
                  height: 1.4,
                ),
              ),
            ),
          );
        }
      }

      // Add spacing between sections
      widgets.add(const SizedBox(height: 30));
    }
    return widgets;
  }
}