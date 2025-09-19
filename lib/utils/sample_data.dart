import 'package:echofinds/models/alternative.dart';

class SampleData {
  static List<Alternative> getSampleAlternatives() {
    return [
      Alternative(
        name: 'LibreOffice',
        description: 'Free and open-source office suite with word processing, spreadsheets, presentations, and more.',
        websiteUrl: 'https://www.libreoffice.org',
        tags: ['office', 'productivity', 'documents', 'spreadsheets'],
        category: 'Software',
        pricingModel: 'Free',
        platforms: ['Windows', 'macOS', 'Linux'],
        rating: 4.2,
        isPopular: true,
      ),
      Alternative(
        name: 'OnlyOffice',
        description: 'Comprehensive office suite compatible with Microsoft Office formats, perfect for team collaboration.',
        websiteUrl: 'https://www.onlyoffice.com',
        tags: ['office', 'collaboration', 'cloud', 'business'],
        category: 'Software', 
        pricingModel: 'Freemium',
        platforms: ['Web', 'Windows', 'macOS', 'Linux'],
        rating: 4.0,
        isPopular: false,
      ),
      Alternative(
        name: 'WPS Office',
        description: 'Lightweight office suite with excellent Microsoft Office compatibility and cloud integration.',
        websiteUrl: 'https://www.wps.com',
        tags: ['office', 'lightweight', 'mobile', 'cloud'],
        category: 'Software',
        pricingModel: 'Freemium',
        platforms: ['Windows', 'macOS', 'Android', 'iOS'],
        rating: 4.1,
        isPopular: true,
      ),
      Alternative(
        name: 'Google Workspace',
        description: 'Cloud-based productivity suite with real-time collaboration features and seamless integration.',
        websiteUrl: 'https://workspace.google.com',
        tags: ['cloud', 'collaboration', 'google', 'business'],
        category: 'Services',
        pricingModel: 'Subscription',
        platforms: ['Web', 'Android', 'iOS'],
        rating: 4.4,
        isPopular: true,
      ),
      Alternative(
        name: 'Zoho Workplace',
        description: 'Complete business suite with office applications, email, and collaboration tools.',
        websiteUrl: 'https://www.zoho.com/workplace',
        tags: ['business', 'collaboration', 'email', 'crm'],
        category: 'Services',
        pricingModel: 'Subscription',
        platforms: ['Web', 'Android', 'iOS'],
        rating: 3.9,
        isPopular: false,
      ),
    ];
  }
  
  static void addSampleFavorites() async {
    // This would be used in development to add sample favorites
    // Not called automatically in production
  }
}