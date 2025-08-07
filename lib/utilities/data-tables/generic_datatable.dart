import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ofoqe_naween/components/dialogs/confirmation_dialog.dart';
import 'package:ofoqe_naween/components/nothing_found.dart';
import 'package:ofoqe_naween/theme/colors.dart';
import 'package:ofoqe_naween/values/strings.dart';

typedef ModelFromMap<T> = T Function(Map<String, dynamic> data, String id);
typedef GetField<T, R> = Comparable<R> Function(T model);
typedef DeleteService<T> = Future<void> Function(String id);
typedef AddEditWidgetBuilder<T> = Widget Function({T? model, String? id});
typedef CellBuilder<T> = List<DataCell> Function(T model);

class GenericDataTable<T> extends StatefulWidget {
  final List<DataColumn> columns;
  final Stream<QuerySnapshot<Map<String, dynamic>>> dataStream;
  final ModelFromMap<T> fromMap;
  final DeleteService<T> deleteService;
  final AddEditWidgetBuilder<T> addEditWidget;
  final CellBuilder<T> cellBuilder;
  final String addTitle;
  final String deleteTitlePrefix;
  final String deleteMessage;
  final String deleteSuccessMessage;
  final String deleteFailureMessage;
  final bool enableSearch;
  final bool enableSort;
  final List<String> searchFields;
  final List<GetField<T, dynamic>> sortFields;

  const GenericDataTable({
    Key? key,
    required this.columns,
    required this.dataStream,
    required this.fromMap,
    required this.deleteService,
    required this.addEditWidget,
    required this.cellBuilder,
    required this.addTitle,
    required this.deleteTitlePrefix,
    required this.deleteMessage,
    required this.deleteSuccessMessage,
    required this.deleteFailureMessage,
    this.enableSearch = false,
    this.enableSort = false,
    this.searchFields = const [],
    this.sortFields = const [],
  }) : super(key: key);

  @override
  _GenericDataTableState<T> createState() => _GenericDataTableState<T>();
}

class _GenericDataTableState<T> extends State<GenericDataTable<T>> {
  final int _pageSize = 11;
  final TextEditingController _searchController = TextEditingController();
  int? _sortColumnIndex;
  bool _sortAscending = true;
  List<QueryDocumentSnapshot<Map<String, dynamic>>>? _filteredDocs;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search(QuerySnapshot<Map<String, dynamic>> snapshot) {
    setState(() {
      _filteredDocs = getFilteredDocs(snapshot);
    });
  }

  void _sort(int columnIndex, bool ascending,
      QuerySnapshot<Map<String, dynamic>> snapshot) {
    if (!widget.enableSort ||
        columnIndex == 0 ||
        columnIndex > widget.sortFields.length) {
      return;
    }
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
      List<QueryDocumentSnapshot<Map<String, dynamic>>> docs =
          getFilteredDocs(snapshot);
      docs.sort((a, b) {
        final fieldA =
            widget.sortFields[columnIndex - 1](widget.fromMap(a.data(), a.id));
        final fieldB =
            widget.sortFields[columnIndex - 1](widget.fromMap(b.data(), b.id));
        return ascending
            ? Comparable.compare(fieldA, fieldB)
            : Comparable.compare(fieldB, fieldA);
      });
      _filteredDocs = docs;
    });
  }

  List<QueryDocumentSnapshot<Map<String, dynamic>>> getFilteredDocs(
      QuerySnapshot<Map<String, dynamic>> snapshot) {
    if (!widget.enableSearch || widget.searchFields.isEmpty) {
      return snapshot.docs;
    }
    String searchText = _searchController.text.toLowerCase();
    return snapshot.docs.where((doc) {
      return widget.searchFields.any((field) {
        return (doc.data()[field]?.toString().toLowerCase() ?? '')
            .contains(searchText);
      });
    }).toList();
  }

  Widget _buildDataTable(QuerySnapshot<Map<String, dynamic>> snapshot) {
    if (_sortColumnIndex == null) {
      _filteredDocs = getFilteredDocs(snapshot);
    }
    if (_filteredDocs != null && _filteredDocs!.isEmpty) {
      return NothingFound();
    }

    return Theme(
      data: Theme.of(context).copyWith(
        cardTheme: Theme.of(context).cardTheme.copyWith(
              elevation: 0,
              margin: EdgeInsets.zero,
              color: Colors.white,
            ),
      ),
      child: SizedBox(
        width: double.infinity,
        child: PaginatedDataTable(
          showEmptyRows: false,
          columns: widget.columns.map((col) {
            final index = widget.columns.indexOf(col);
            if (widget.enableSort &&
                index > 0 &&
                index <= widget.sortFields.length) {
              return DataColumn(
                label: col.label,
                onSort: (i, ascending) => _sort(i, ascending, snapshot),
              );
            }
            return col;
          }).toList(),
          rowsPerPage: _filteredDocs!.length < _pageSize
              ? _filteredDocs!.length
              : _pageSize,
          sortColumnIndex: _sortColumnIndex,
          sortAscending: _sortAscending,
          source: GenericDataSource<T>(
            documents: _filteredDocs!,
            context: context,
            fromMap: widget.fromMap,
            deleteService: widget.deleteService,
            addEditWidget: widget.addEditWidget,
            cellBuilder: widget.cellBuilder,
            expectedCellCount: widget.columns.length - 2,
            deleteTitlePrefix: widget.deleteTitlePrefix,
            deleteMessage: widget.deleteMessage,
            deleteSuccessMessage: widget.deleteSuccessMessage,
            deleteFailureMessage: widget.deleteFailureMessage,
            onUpdate: () {
              setState(() {
                _filteredDocs = null;
              });
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: widget.dataStream,
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return Column(
          children: [
            if (widget.enableSearch)
              Container(
                color: AppColors.appBarBG,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: Strings.search,
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () => _search(snapshot.data!),
                    ),
                    prefixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        if (_searchController.text.isNotEmpty) {
                          _searchController.clear();
                          _search(snapshot.data!);
                        }
                      },
                    ),
                  ),
                  onSubmitted: (value) => _search(snapshot.data!),
                ),
              ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: _buildDataTable(snapshot.data!),
              ),
            ),
          ],
        );
      },
    );
  }
}

class GenericDataSource<T> extends DataTableSource {
  final List<QueryDocumentSnapshot<Map<String, dynamic>>> documents;
  final BuildContext context;
  final ModelFromMap<T> fromMap;
  final DeleteService<T> deleteService;
  final AddEditWidgetBuilder<T> addEditWidget;
  final CellBuilder<T> cellBuilder;
  final int expectedCellCount;
  final String deleteTitlePrefix;
  final String deleteMessage;
  final String deleteSuccessMessage;
  final String deleteFailureMessage;
  final VoidCallback onUpdate;

  GenericDataSource({
    required this.documents,
    required this.context,
    required this.fromMap,
    required this.deleteService,
    required this.addEditWidget,
    required this.cellBuilder,
    required this.expectedCellCount,
    required this.deleteTitlePrefix,
    required this.deleteMessage,
    required this.deleteSuccessMessage,
    required this.deleteFailureMessage,
    required this.onUpdate,
  });

  @override
  DataRow getRow(int index) {
    if (index >= documents.length) {
      return const DataRow(cells: []);
    }
    final model = fromMap(documents[index].data(), documents[index].id);
    final cells = cellBuilder(model);
    assert(cells.length == expectedCellCount,
        'cellBuilder must return $expectedCellCount cells for the data columns');
    return DataRow(
      cells: [
        DataCell(Text((index + 1).toString())), // Symbolic numbering
        ...cells,
        DataCell(
          PopupMenuButton<int>(
            onSelected: (i) async {
              switch (i) {
                case 1: // Edit
                  await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text(Strings.edit),
                        content: addEditWidget(
                            model: model, id: documents[index].id),
                      );
                    },
                  );
                  onUpdate(); // Trigger rebuild after edit
                  break;
                case 2: // Delete
                  await showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return ConfirmationDialog(
                        title: deleteTitlePrefix +
                            (documents[index].data()['name']?.toString() ?? ''),
                        message: deleteMessage,
                        onConfirm: () async {
                          final scaffoldMessenger =
                              ScaffoldMessenger.of(context);
                          Navigator.of(context).pop();
                          try {
                            await deleteService(documents[index].id);
                            scaffoldMessenger.showSnackBar(
                              SnackBar(
                                content: Text(deleteSuccessMessage),
                                backgroundColor: Colors.green,
                              ),
                            );
                            onUpdate(); // Trigger rebuild after delete
                          } catch (e) {
                            scaffoldMessenger.showSnackBar(
                              SnackBar(
                                content: Text(deleteFailureMessage),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        },
                      );
                    },
                  );
                  break;
              }
            },
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 1,
                child: ListTile(
                  leading: Icon(Icons.edit, color: Colors.blue),
                  title: Text(Strings.edit),
                ),
              ),
              const PopupMenuItem(
                value: 2,
                child: ListTile(
                  leading: Icon(Icons.delete, color: Colors.red),
                  title: Text(Strings.delete),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  bool get isRowCountApproximate => false;

  @override
  int get rowCount => documents.length;

  @override
  int get selectedRowCount => 0;

  int get rowHeight => 56;
}
