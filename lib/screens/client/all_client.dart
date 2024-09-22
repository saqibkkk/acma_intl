import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import '../../../API/realtime_crud.dart';
import '../../../Controllers/theme_controller.dart';
import '../../../utils.dart';
import '../../Controllers/internet.dart';
import '../../Models/client_model.dart';
import 'add_client.dart';
import 'client_bills.dart';
import 'edit_client.dart';
import 'generate_client_bill.dart';

class AllClients extends StatefulWidget {
  const AllClients({super.key});

  @override
  State<AllClients> createState() => _AllClientsState();
}

class _AllClientsState extends State<AllClients> {
  final ThemeController theme = Get.find();
  final InternetController internet = Get.find();
  List<ClientModel> clientList = [];
  List<ClientModel> filteredClientsList = [];
  final TextEditingController _searchController = TextEditingController();
  bool isLoading = false;
  List<bool> editRemoveBtn = [];

  Future<void> _fetchClientsData() async {
    setState(() {
      isLoading = true;
    });
    bool hasInternet = await internet.checkInternet();
    if (!hasInternet) {
      Utils.showSnackBar('Error', 'No Internet Connection.');
      setState(() {
        isLoading = false;
      });
      return;
    }
    clientList = await Api.getClient();
    setState(() {
      isLoading = false;
      filteredClientsList = clientList;
      editRemoveBtn = List<bool>.filled(clientList.length, false);
    });
  }

  void _filterEmployees() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      filteredClientsList = clientList
          .where((client) => client.name.toLowerCase().contains(query))
          .toList();
    });
  }

  @override
  void initState() {
    _fetchClientsData();
    _searchController.addListener(_filterEmployees);
    super.initState();
  }

  @override
  void dispose() {
    _fetchClientsData();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => GestureDetector(
        onTap: () {
          setState(() {
            FocusScope.of(context).unfocus();
            for (int i = 0; i < editRemoveBtn.length; i++) {
              editRemoveBtn[i] = false;
            }
          });
        },
        child: Scaffold(
          backgroundColor: theme.scaffoldBg.value,
          floatingActionButton: SizedBox(
            height: 50,
            width: 120,
            child: FloatingActionButton(
              backgroundColor: theme.iconColor.value,
              onPressed: () {
                Get.to(const AddClient());
              },
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'Add Client',
                  style: TextStyle(color: theme.textLight.value),
                ),
              ),
            ),
          ),
          body: isLoading
              ? Center(child: Utils.showProgressBar(context))
              : SafeArea(
                  child: Column(
                    children: [
                      Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 8),
                          child: Utils.customTextFormField(
                              onTap: () {
                                setState(() {
                                  FocusScope.of(context).unfocus();
                                });
                              },
                              icon: FontAwesomeIcons.magnifyingGlass,
                              controller: _searchController,
                              keyboardType: TextInputType.text,
                              label: 'Search by Client Name...',
                              readOnly: false,
                              obscureText: false,
                              capital: TextCapitalization.words,
                              textColor: theme.textDark.value,
                              bgColor: theme.cardBtn.value)),
                      Expanded(
                        child: filteredClientsList.isEmpty
                            ? Center(
                                child: Text(
                                "No Clients available!",
                                style: TextStyle(
                                    color: theme.textDark.value,
                                    fontWeight: FontWeight.w500,
                                    fontSize: 20),
                              ))
                            : ListView.builder(
                                itemCount: filteredClientsList.length,
                                padding: const EdgeInsets.only(bottom: 70),
                                itemBuilder: (context, index) {
                                  ClientModel clients =
                                      filteredClientsList[index];
                                  return InkWell(
                                    onTap: () {
                                      Get.to(ClientBills(
                                        client: clients,
                                      ));
                                    },
                                    onLongPress: () {
                                      setState(() {
                                        for (int i = 0;
                                            i < editRemoveBtn.length;
                                            i++) {
                                          if (i != index) {
                                            editRemoveBtn[i] = false;
                                          }
                                        }
                                        editRemoveBtn[index] =
                                            !editRemoveBtn[index];
                                      });
                                    },
                                    child: Card(
                                      margin: const EdgeInsets.symmetric(
                                          horizontal: 15, vertical: 8),
                                      color: theme.cardBtn.value,
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 12, vertical: 10),
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  clients.name,
                                                  style: TextStyle(
                                                      color:
                                                          theme.textDark.value,
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                                InkWell(
                                                    onTap: () {
                                                      Get.to(Get.to(
                                                          GenerateClientBill(
                                                        client: clients,
                                                      )));
                                                    },
                                                    child: Text(
                                                      'Generate bill',
                                                      style: TextStyle(
                                                          color: theme
                                                              .greenPrimary
                                                              .value,
                                                          fontSize: 12),
                                                    ))
                                              ],
                                            ),
                                            Divider(
                                              color: theme.iconColor.value,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Text(
                                                  'Phone: ${clients.phone}',
                                                  style: TextStyle(
                                                    color: theme.textDark.value,
                                                    fontSize: 14,
                                                  ),
                                                ),
                                                editRemoveBtn[index]
                                                    ? Row(
                                                        children: [
                                                          InkWell(
                                                              onTap: () {
                                                                Get.to(EditClient(
                                                                    client:
                                                                        clients));
                                                              },
                                                              child: const Icon(
                                                                FontAwesomeIcons
                                                                    .pencil,
                                                                color: Colors
                                                                    .green,
                                                              )),
                                                          const SizedBox(
                                                            width: 20,
                                                          ),
                                                          InkWell(
                                                            onTap: () {
                                                              Utils
                                                                  .customAlertBox(
                                                                      client:
                                                                          clients,
                                                                      context:
                                                                          context,
                                                                      headingText:
                                                                          'Warning',
                                                                      insideText:
                                                                          'All data of your client ${clients.name} will be deleted',
                                                                      onConfirmPress:
                                                                          () async {
                                                                        bool
                                                                            hasInternet =
                                                                            await internet.checkInternet();
                                                                        if (!hasInternet) {
                                                                          Utils.showSnackBar(
                                                                              'Error',
                                                                              'No Internet Connection.');
                                                                          return;
                                                                        }
                                                                        await Api.deleteClient(
                                                                            clientId:
                                                                                clients.clientId);
                                                                        Get.back();
                                                                        Utils.showSnackBar(
                                                                            'Successful',
                                                                            'Your client ${clients.name} has been deleted');
                                                                        clientList
                                                                            .clear();
                                                                        await _fetchClientsData();
                                                                      });
                                                            },
                                                            child: const Icon(
                                                              FontAwesomeIcons
                                                                  .trash,
                                                              color: Colors.red,
                                                            ),
                                                          )
                                                        ],
                                                      )
                                                    : const SizedBox.shrink()
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              'Address: ${clients.address}',
                                              style: TextStyle(
                                                color: theme.textDark.value,
                                                fontSize: 14,
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                      )
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
