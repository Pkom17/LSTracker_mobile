// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:lstrackers/models/axe_models.dart';


// class ApiService {
//   /*url du serveur en ligne a inserer */
//   static const String apiUrl = '#';

//   /*Fonction pour Récupérer les utilisateurs depuis l'API des axes*/
//   Future<List<AxeModels>> axeDataOnline() async {
//     final response = await http.get(Uri.parse(apiUrl));
//     if (response.statusCode == 200) {
//       List<dynamic> data = json.decode(response.body);
//       return data.map((item) => AxeModels.formJson(item)).toList();
//     } else {
//       throw Exception("Echec de chargement des données sur les axes");
//     }
//   }

//   /*Ajouter un axe via l'API du le serveur*/
//   Future<void> addDataOnline(AxeModels axeModels) async {
//     final response = await http.post(
//       Uri.parse(apiUrl),
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode(axeModels.toMap()),
//     );
//     if (response.statusCode != 201) {
//       throw Exception('Echec lors de l\' ajout  des données axes');
//     }
//   }

//   /*Mettre à jour un utilisateur via l'API d'un axes */

//   Future<void> updateDataOnline(AxeModels axeModels) async {
//     final response = await http.put(
//       Uri.parse("$apiUrl/${axeModels.id}"),
//       headers: {'Content-Type': 'application/json'},
//       body: json.encode(axeModels.toMap()),
//     );
//     if (response.statusCode != 200) {
//       throw Exception('Echec de mise à jour des données des axes');
//     }
//   }
//   /*Supprimer un axe via l'API*/

//   Future<void> deleteDataOnline(int id) async {
//     final response = await http.delete(Uri.parse("$apiUrl/$id"));
//     if (response.statusCode != 200) {
//       throw Exception("Echec de la suppression des données de l'axe");
//     }
//   }



//   Future<void> deleteCollecteSiteOnline(int idsite) async {
//     final response = await http.delete(Uri.parse("$apiUrl/$idsite"));
//     if (response.statusCode != 200) {
//       throw Exception("Echec de chargement des données");
//     }
//   }
// }


