// case_studies.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shimmer/shimmer.dart';

import '../routes.dart';

class CaseStudy {
  final String id;
  final String title;
  final String imageAssetPath;
  final String summary;
  final List<String> categories;
  final String projectDetails;
  final String challenge;
  final String solution;
  final String pdfAssetPath;

  const CaseStudy({
    required this.id,
    required this.title,
    required this.imageAssetPath,
    required this.summary,
    required this.categories,
    required this.projectDetails,
    required this.challenge,
    required this.solution,
    required this.pdfAssetPath,
  });
}

const List<CaseStudy> allCaseStudies = [
  CaseStudy(
    id: "1",
    title: "Homewood Grove Retirement Village",
    imageAssetPath: "assets/pdfs/CASESTUDIES/frontpages/Homewood_Grove.jpeg",
    summary: "Ultra-low output bespoke in-screed heating cables for luxury apartments.",
    categories: ["Underfloor Heating", "Residential"],
    projectDetails: "Homewood Grove is a new-build luxury retirement village of 116 apartments. Sustainability was at the forefront, with each home being supplied with an all-electric underfloor heating system operating at a super low output for stable temperatures.",
    challenge: "The project required a heating system and installation method that would allow each apartment to be screeded in a single pour before the stud walls were installed. This approach was designed to reduce costs and speed up the project timeline significantly.",
    solution: "Heat Mat provided an ultra-low output in-screed heating cable specially designed for the project's requirements. A unique fixing method allowed for a speedy installation and a single pour of screed per apartment, saving time and money. The systems were commissioned by Heat Mat and have worked faultlessly.",
    pdfAssetPath: "assets/pdfs/CASESTUDIES/Case_Study_Homewood_Grove.pdf",
  ),
  CaseStudy(
    id: "2",
    title: "Pengersick Castle, Cornwall",
    imageAssetPath: "assets/pdfs/CASESTUDIES/frontpages/Castle_Cornwall.jpeg",
    summary: "Essential refurbishment work to improve facilities for visitors.",
    categories: ["Underfloor Heating", "Commercial", "Bespoke Projects"],
    projectDetails: "Pengersick Castle, one of the country's most haunted historic properties, was undergoing essential refurbishment to improve facilities for visitors at ghost nights and historical talks. The goal was to take the chill off these events for guests.",
    challenge: "Due to the age of the building, heaters could not be placed on the granite walls. An underfloor heating system was required beneath new slate floor tiles to improve visitor comfort, installed in a historic kitchen floor that had been in poor condition.",
    solution: "Heat Mat specified a 200W/sqm heating mat system for the high heat-loss space. The mats were laid onto 20mm thermal insulation boards for maximum energy efficiency and a faster warm-up. The system is controlled by a programmable NGT thermostat and has successfully taken the chill off events at the castle.",
    pdfAssetPath: "assets/pdfs/CASESTUDIES/Case_Study_Castle_Cornwall.pdf",
  ),
  CaseStudy(
    id: "3",
    title: "Hurston Mill, Sussex",
    imageAssetPath: "assets/pdfs/CASESTUDIES/frontpages/Hurston_Mill_Sussex.jpeg",
    summary: "Technical experts from Heat Mat design a solution whilst maintaining aesthetic integrity of the building.",
    categories: ["Underfloor Heating", "Residential"],
    projectDetails: "The owners of an idyllic rural home, not on mains gas, were building a new extension for a dining room and wet room. They wanted to utilize all wall space, so panel heaters were not an option. An energy-efficient electric system was required as the sole source of heating.",
    challenge: "An affordable, fast-reacting system was needed for the wet room, and a sole source of heating was required for the dining room. The solution had to be designed around the power available on-site while keeping installation costs down and disruption minimal.",
    solution: "Heat Mat specified a 6mm In-screed heating cable for the dining room and fast-reacting 200W/sqm heating mats over insulation for the wet room. The specified products were fitted in less than half a day, providing a cost-effective and efficient solution that achieved a warm floor in under 30 minutes in the wet room.",
    pdfAssetPath: "assets/pdfs/CASESTUDIES/Case_Study_Hurston_Mill_Sussex.pdf",
  ),
  CaseStudy(
    id: "4",
    title: "Oyster Reach, Kent",
    imageAssetPath: "assets/pdfs/CASESTUDIES/frontpages/Oyster_Reach_Kent.jpeg",
    summary: "Heat Mat’s technical expertise helped to deliver a luxurious and low-energy heating system.",
    categories: ["Underfloor Heating", "Residential"],
    projectDetails: "Oyster Reach is a group of contemporary Passivhaus apartments. The 'fabric first' design approach minimizes heat loss, reducing the need for traditional heating systems. The goal was to provide a flexible and energy-efficient heating solution for the five apartments.",
    challenge: "To complement the innovative, premium, and low-energy approach of a Passivhaus build. The heating needed to be a low-output system that could store heat in the screed and top it up as required, running on electricity from renewable sources.",
    solution: "Heat Mat's Danish-manufactured In-screed heating cables were installed, covered with 70mm of screed. The system generates a low output of approximately 130W/sqm, storing heat within the screed. This resulted in extremely low running costs, with predicted energy costs as little as £175 a year.",
    pdfAssetPath: "assets/pdfs/CASESTUDIES/Case_Study_Oyster_Reach_Kent.pdf",
  ),
  CaseStudy(
    id: "5",
    title: "Edinburgh Zoo, Tiger Enclosure",
    imageAssetPath: "assets/pdfs/CASESTUDIES/frontpages/Edinburgh_Zoo.jpeg",
    summary: "Tigers treated to a warmer den courtesy of Heat Mat’s 200W heating mats.",
    categories: ["Underfloor Heating", "Commercial", "Bespoke Projects"],
    projectDetails: "The Royal Zoological Society of Scotland (RZSS) Edinburgh Zoo invested in a new enclosure for a breeding pair of Sumatran tigers. The 'Tiger Tracks' enclosure required heated areas in the den to mimic the warmth of their native Indonesia.",
    challenge: "To develop a heating solution for three dens and a cubbing box, providing a comfortable environment for the endangered tigers to relax in. The system needed to be robust and controllable by zoo staff.",
    solution: "High output 200W heating mats were fitted on top of concrete plinths, beneath bonded sand and soil inside the dens. These mats keep the majestic animals warm, mimicking their natural habitat and encouraging them outside regardless of weather. The system is controlled by intelligent NGTouch thermostats.",
    pdfAssetPath: "assets/pdfs/CASESTUDIES/Case_Study_Edinburgh_Zoo.pdf",
  ),
  CaseStudy(
    id: "6",
    title: "Hastings Pier, Sussex",
    imageAssetPath: "assets/pdfs/CASESTUDIES/frontpages/Hastings_Pier.jpeg",
    summary: "£14.2m refurbishment of historic Hastings Pier.",
    categories: ["Underfloor Heating", "Commercial"],
    projectDetails: "During the £14.2m refurbishment of the historic Hastings Pier, a heating system was required for the new Pavilion Restaurant & Bar.",
    challenge: "A traditional wet heating system was ruled out as it would have been too heavy for the pier's flooring structure. A lightweight system was required that would not add unnecessary load or stress to the surface.",
    solution: "Electric underfloor heating was the ideal solution due to its low weight. A combination of 160W heating mats and loose 3mm heating cable was installed across three zones, controlled by NGTouch thermostats. This provided a flexible and lightweight warming solution, guaranteeing the integrity of the floor for years to come.",
    pdfAssetPath: "assets/pdfs/CASESTUDIES/Case-Study-Hastings-Pier.pdf",
  ),
  CaseStudy(
    id: "7",
    title: "Linden House, Horsham",
    imageAssetPath: "assets/pdfs/CASESTUDIES/frontpages/Linden_House.jpeg",
    summary: "Impressive conversion project in Sussex.",
    categories: ["Underfloor Heating", "Residential"],
    projectDetails: "Linden House is a contemporary conversion of an impressive stone commercial building into 63 high-spec apartments. The remit was to use the finest materials throughout, and the electrical contractors approached Heat Mat for an underfloor heating solution.",
    challenge: "To provide a sole source of heating for each apartment that was compatible with various floor coverings (hardwood, carpet, porcelain tiles) and easy to install. The specification evolved as the development changed, requiring a flexible approach.",
    solution: "Heat Mat's 160W heating mats were chosen for their compatibility and ease of installation. They were fitted onto 10mm thermal insulation boards to ensure little downward heat loss and increase warm-up times. The system is controlled by a colour touchscreen NGTouch thermostat suited to the modern interior.",
    pdfAssetPath: "assets/pdfs/CASESTUDIES/Case-Study-Linden-House.pdf",
  ),
  CaseStudy(
    id: "8",
    title: "Little Kelham, Sheffield",
    imageAssetPath: "assets/pdfs/CASESTUDIES/frontpages/Little_Kelham.jpeg",
    summary: "Wall heating system in low carbon energy efficient new build development.",
    categories: ["Underfloor Heating", "Residential"],
    projectDetails: "Little Kelham is a new-build development of highly energy-efficient, low-carbon homes. The homes are super airtight and well-insulated, so conventional central heating was not required. A flexible and modern heating solution was specified.",
    challenge: "The developer wanted a heating system within the walls ('wall heating') rather than the floors, to give homeowners complete flexibility over their choice of flooring. The system needed to integrate with the developer's own 'smart home' software.",
    solution: "Heat Mat worked with the developers to apply wall heating systems. A combination of 160W and 200W wall heating mats were fitted into the walls, mounted onto board, and plastered over. The system integrates seamlessly into the home automation, providing a discrete, low-output, quick-response heating solution.",
    pdfAssetPath: "assets/pdfs/CASESTUDIES/Case-Study-Little-Kelham.pdf",
  ),
  CaseStudy(
    id: "9",
    title: "RAF Wainfleet, Lynx Helicopter",
    imageAssetPath: "assets/pdfs/CASESTUDIES/frontpages/Lynx_Helicopter.jpeg",
    summary: "The conversion of an iconic Lynx Helicopter into holiday accommodation in Lincolnshire.",
    categories: ["Underfloor Heating", "Bespoke Projects"],
    projectDetails: "This unique renovation project involved converting an iconic Military Westland Lynx Helicopter into holiday accommodation. A heating solution was needed for this 'sky-high' project.",
    challenge: "To provide a cosy interior for the 3.3m² space within the helicopter, which would serve as a self-contained glamping pod. The system needed to be remotely controllable to meet guest's demands.",
    solution: "Heat Mat specified the 150W Combymat System. The heating mats were fitted onto 6mm of foam insulation on top of a plywood base, with a final floor covering of laminate. A WiFi-enabled NGTouch thermostat controls the heating, allowing the owner to adjust it remotely.",
    pdfAssetPath: "assets/pdfs/CASESTUDIES/CS_Lynx_Helicopter_Email.pdf",
  ),
  CaseStudy(
    id: "10",
    title: "Domestic Drive, Oldham",
    imageAssetPath: "assets/pdfs/CASESTUDIES/frontpages/Domestic_Drive_Oldham.jpeg",
    summary: "A safe solution for a steep domestic driveway.",
    categories: ["Ice & Snow", "External"],
    projectDetails: "The owners of a house with a very steep block-paved driveway in Oldham required a solution to keep it free of ice and snow during the winter months.",
    challenge: "To provide an effective heating system that could be retrofitted into the existing driveway without the need to replace the entire surface. The system needed to be powerful enough to cope with the steep gradient and harsh winter conditions.",
    solution: "Heat Mat’s driveway heating cables were installed into channels cut into the existing block paving. The cables were laid in the tyre track areas to provide a safe passage for vehicles. The system is automatically controlled by a sensor that detects both temperature and moisture, ensuring it only operates when needed.",
    pdfAssetPath: "assets/pdfs/CASESTUDIES/Case_Study_Domestic_Drive_Oldham.pdf",
  ),
  CaseStudy(
    id: "11",
    title: "Donkey Sanctuary, Derby",
    imageAssetPath: "assets/pdfs/CASESTUDIES/frontpages/Donkey_Sanctuary_Derby.jpeg",
    summary: "Keeping the pathways safe for volunteers and donkeys.",
    categories: ["Ice & Snow", "External"],
    projectDetails: "The Donkey Sanctuary in Derbyshire needed to ensure the pathways and access ramps around their new visitor centre were safe for their volunteers and, of course, the donkeys.",
    challenge: "To provide a heating solution for a large outdoor area that would prevent the formation of ice and snow, particularly on the ramped sections. The system needed to be robust enough to handle foot and hoof traffic.",
    solution: "Heat Mat supplied exterior heating cables which were laid beneath a new tarmac surface. The system covers the main pathways and ramps, providing a safe and clear surface throughout the winter. It is operated by a fully automated weather-sensing controller for energy-efficient operation.",
    pdfAssetPath: "assets/pdfs/CASESTUDIES/Case_Study_Donkey_Sanctuary_Derby.pdf",
  ),
  CaseStudy(
    id: "12",
    title: "Driveway, Millgate Homes",
    imageAssetPath: "assets/pdfs/CASESTUDIES/frontpages/Driveway_Millgate_Homes.jpeg",
    summary: "A heated driveway for a luxury new-build property.",
    categories: ["Ice & Snow", "External", "Residential"],
    projectDetails: "As part of a luxury new-build project by Millgate Homes, a heated driveway was required to ensure safe access to the property's garage, which was located on a slope.",
    challenge: "To install a reliable and effective driveway heating system that would integrate seamlessly with the high-end finish of the property. The system needed to be automated and energy-efficient.",
    solution: "Heat Mat’s driveway heating cables were installed in the tyre tracks of the sloping driveway. The system is controlled by an intelligent ground-level sensor that activates the heating only when both the temperature drops and moisture is present, preventing ice and snow from forming.",
    pdfAssetPath: "assets/pdfs/CASESTUDIES/Case_Study_Driveway_Millgate_Homes.pdf",
  ),
  CaseStudy(
    id: "13",
    title: "Driveway, Millgate Homes, Englemer",
    imageAssetPath: "assets/pdfs/CASESTUDIES/frontpages/Driveway_Millgate_Homes_Englemere.jpeg",
    summary: "Ensuring safe access for a prestigious development.",
    categories: ["Ice & Snow", "External", "Residential"],
    projectDetails: "For another prestigious Millgate Homes development at Englemere, a driveway heating solution was needed for a property with a steep and winding access road.",
    challenge: "To provide a safe and clear path for vehicles on a long and curved driveway, which would be particularly hazardous in icy conditions. The installation needed to be completed efficiently to avoid delays in the overall project.",
    solution: "Heat Mat designed a bespoke driveway heating system that followed the curves of the road, heating the tyre track areas. The system uses robust heating cables embedded in the asphalt and is controlled by a fully automated weather-sensing system to ensure it operates efficiently.",
    pdfAssetPath: "assets/pdfs/CASESTUDIES/Case_Study_Driveway_Millgate_Homes_Englemere.pdf",
  ),
  CaseStudy(
    id: "14",
    title: "Family Home, West Sussex",
    imageAssetPath: "assets/pdfs/CASESTUDIES/frontpages/Family_West_Sussex.jpeg",
    summary: "A speedy and efficient heating solution for a family kitchen/diner refurbishment.",
    categories: ["Underfloor Heating", "Residential"],
    projectDetails: "Homeowners refurbishing their kitchen/diner wanted to lay a high-quality vinyl floor. They were limited on wall space for radiators and wanted to ensure the floor was warm for their children.",
    challenge: "To provide a speedy warm-up time under a vinyl floor, prevent downward heat loss, and supply a thermostat that matched the brushed aluminium kitchen appliances. The installation needed to be quick to minimize kitchen downtime.",
    solution: "Heat Mat specified 160W/sqm heating mats over 10mm thermal insulation boards. The mats were covered with a flexible, fibre-reinforced levelling compound which set in less than four hours. A premium NGT thermostat with a chrome surround was supplied, perfectly matching the kitchen appliances and providing a beautifully warm room.",
    pdfAssetPath: "assets/pdfs/CASESTUDIES/Case_Study_Family_West_Sussex.pdf",
  ),
  CaseStudy(
    id: "15",
    title: "Greatmoor Ramp",
    imageAssetPath: "assets/pdfs/CASESTUDIES/frontpages/Greatmoor_Ramp.jpeg",
    summary: "Ensuring safe access for waste management vehicles.",
    categories: ["Ice & Snow", "External", "Commercial"],
    projectDetails: "The Greatmoor Energy from Waste facility required a heating solution for its main access ramp to ensure waste delivery vehicles could operate safely all year round.",
    challenge: "To provide a robust and reliable heating system for a large, high-traffic ramp. The system needed to be powerful enough to prevent ice and snow build-up for heavy goods vehicles and be fully automated.",
    solution: "Heat Mat installed a high-output ramp heating system using durable heating cables embedded in the concrete ramp surface. The system is controlled by a sophisticated weather station that monitors temperature, moisture, and snow, ensuring the ramp remains clear and safe in all winter conditions.",
    pdfAssetPath: "assets/pdfs/CASESTUDIES/Case_Study_Greatmoor_Ramp.pdf",
  ),
  CaseStudy(
    id: "16",
    title: "JCB Helipad Heating System",
    imageAssetPath: "assets/pdfs/CASESTUDIES/frontpages/JCB_Helipad_Heating_System.jpeg",
    summary: "A frost-free helipad for safe landings.",
    categories: ["Ice & Snow", "External", "Bespoke Projects"],
    projectDetails: "JCB required a heating system for their helipad to ensure it remained free of frost and ice, allowing for safe helicopter landings at all times.",
    challenge: "To design and install a heating system for a circular helipad that would provide even heat distribution across the entire surface. The system needed to be robust and reliable for this critical application.",
    solution: "Heat Mat designed a bespoke helipad heating system using their most durable heating cables. The cables were laid in a specific pattern to ensure complete and even coverage. The system is controlled by an automated weather-sensing unit, providing a safe and operational helipad throughout the winter.",
    pdfAssetPath: "assets/pdfs/CASESTUDIES/Case_Study_JCB_Helipad_Heating_System.pdf",
  ),
  CaseStudy(
    id: "17",
    title: "LG Arena Roof",
    imageAssetPath: "assets/pdfs/CASESTUDIES/frontpages/LG_Arena_Roof.jpeg",
    summary: "Preventing snow and ice build-up on a large arena roof.",
    categories: ["Ice & Snow", "External", "Commercial"],
    projectDetails: "The LG Arena (now Resorts World Arena) in Birmingham needed a solution to prevent snow and ice from accumulating on its large roof, which could pose a safety risk to the public below.",
    challenge: "To provide a roof heating system for a vast and complex roof structure. The system needed to be effective in preventing ice dams and icicles from forming along the roof edges and gutters.",
    solution: "Heat Mat installed a comprehensive roof and gutter heating system using self-regulating heating cables. The cables were run along the roof edges and inside the gutters and downpipes to create clear channels for meltwater to drain away safely. The system is automatically controlled for energy efficiency.",
    pdfAssetPath: "assets/pdfs/CASESTUDIES/Case_Study_LG_Arena_Roof.pdf",
  ),
  CaseStudy(
    id: "18",
    title: "Lee Valley Ice Centre",
    imageAssetPath: "assets/pdfs/CASESTUDIES/frontpages/Lee_Valley_Ice_Centre.jpeg",
    summary: "Frost protection for a new ice centre.",
    categories: ["Ice & Snow", "External", "Bespoke Projects"],
    projectDetails: "The new Lee Valley Ice Centre required a frost protection system for the ground beneath its twin ice rinks to prevent the ground from freezing and causing structural damage.",
    challenge: "To provide a reliable and long-lasting heating system that would be embedded deep within the building's foundations. The system needed to provide a low and consistent level of heat to prevent frost heave.",
    solution: "Heat Mat supplied a specialised ground frost protection system using their robust in-concrete heating cables. The cables were installed in the sub-floor before the main concrete slab was poured. This system ensures the structural integrity of the building by preventing the ground from freezing.",
    pdfAssetPath: "assets/pdfs/CASESTUDIES/Case_Study_Lee_Valley_Ice_Centre.pdf",
  ),
  CaseStudy(
    id: "19",
    title: "Social Housing",
    imageAssetPath: "assets/pdfs/CASESTUDIES/frontpages/Social_Housing.jpeg",
    summary: "A cost-effective heating solution for social housing.",
    categories: ["Underfloor Heating", "Residential"],
    projectDetails: "A housing association required an affordable and efficient heating solution for a new development of social housing apartments.",
    challenge: "To provide a primary heating system that was cost-effective to install and run, while also being easy for tenants to control. The system needed to be reliable and low-maintenance.",
    solution: "Heat Mat supplied their 160W/sqm underfloor heating mats for the living areas and bathrooms of the apartments. This provided a comfortable and evenly distributed heat source. The systems were paired with simple-to-use programmable thermostats, giving tenants control over their heating and helping to manage energy costs.",
    pdfAssetPath: "assets/pdfs/CASESTUDIES/Case_Study_Social_Housing.pdf",
  ),
  CaseStudy(
    id: "20",
    title: "Walkers Crisps",
    imageAssetPath: "assets/pdfs/CASESTUDIES/frontpages/Walkers_Crisps.jpeg",
    summary: "Roof and gutter heating for a major food production facility.",
    categories: ["Ice & Snow", "External", "Commercial"],
    projectDetails: "The Walkers Crisps factory in Leicester needed to prevent ice and snow from causing blockages in the gutters and downpipes of its extensive roof, which could lead to water damage.",
    challenge: "To provide a reliable and effective roof and gutter heating solution for a large industrial building. The system needed to be able to cope with heavy snowfall and be safe for use on a food production site.",
    solution: "Heat Mat installed a self-regulating roof and gutter heating system. The heating cables were fitted inside the gutters and downpipes to maintain a clear path for meltwater. The self-regulating nature of the cables ensures that they only draw power when and where it is needed, making the system both safe and energy-efficient.",
    pdfAssetPath: "assets/pdfs/CASESTUDIES/Case_Study_Walkers_Crisps.pdf",
  ),
];

class CaseStudiesScreen extends StatefulWidget {
  const CaseStudiesScreen({super.key});

  @override
  State<CaseStudiesScreen> createState() => _CaseStudiesScreenState();
}

class _CaseStudiesScreenState extends State<CaseStudiesScreen> {
  static const _categories = <String>[
    'All', 'Underfloor Heating', 'Ice & Snow', 'Residential', 'Commercial', 'External', 'Bespoke Projects'
  ];

  String selectedCategory = 'All';
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final studies = allCaseStudies.where((study) {
      final matchesCategory = selectedCategory == 'All' || study.categories.contains(selectedCategory);
      final q = searchQuery.trim();
      final matchesSearch = q.isEmpty ||
          study.title.toLowerCase().contains(q.toLowerCase()) ||
          study.summary.toLowerCase().contains(q.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text('Case Studies', style: GoogleFonts.raleway()),
        backgroundColor: const Color(0xFFf89f37),
        foregroundColor: Colors.white,
        actions: const [Padding(
          padding: EdgeInsets.only(right: 12),
          child: Icon(Icons.library_books, color: Colors.white),
        )],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              onChanged: (v) => setState(() => searchQuery = v),
              decoration: InputDecoration(
                labelText: 'Search by keyword',
                labelStyle: GoogleFonts.raleway(),
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFf89f37)),
                ),
              ),
              style: GoogleFonts.raleway(color: Colors.black87),
            ),
          ),
          SizedBox(
            height: 44,
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemBuilder: (_, i) {
                final cat = _categories[i];
                final selected = cat == selectedCategory;
                return FilterChip(
                  label: Text(cat, style: GoogleFonts.raleway()),
                  selected: selected,
                  onSelected: (_) => setState(() => selectedCategory = cat),
                  selectedColor: const Color(0xFFf89f37),
                  showCheckmark: false,
                  labelStyle: GoogleFonts.raleway(
                    color: selected ? Colors.white : Colors.black54,
                  ),
                  side: const BorderSide(color: Color(0xFFf89f37)),
                );
              },
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemCount: _categories.length,
            ),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              itemBuilder: (_, i) => _CaseStudyCard(
                study: studies[i],
                onTap: () => Navigator.pushNamed(
                  context,
                  Routes.caseStudyDetail,
                  arguments: studies[i].id,
                ),
              ),
              separatorBuilder: (_, __) => const SizedBox(height: 16),
              itemCount: studies.length,
            ),
          ),
        ],
      ),
    );
  }
}

class _CaseStudyCard extends StatelessWidget {
  final CaseStudy study;
  final VoidCallback onTap;
  const _CaseStudyCard({required this.study, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.asset(
                study.imageAssetPath,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const _ShimmerPlaceholder();
                },
              ),
            ),
            Container(
              color: const Color(0xFF292e37),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(study.title,
                    style: GoogleFonts.raleway(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(study.summary,
                    style: GoogleFonts.raleway(
                      color: const Color(0xFFd3d3d3),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _ShimmerPlaceholder extends StatelessWidget {
  const _ShimmerPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Container(
          color: Colors.black12,
          alignment: Alignment.center,
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.contain,
              color: Colors.black26,
            ),
          ),
        ),
        Opacity(
          opacity: 0.7,
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}