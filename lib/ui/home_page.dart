import 'dart:io';

import 'package:f_contact_ex/domain/contact.dart';
import 'package:f_contact_ex/helpers/contact_helper.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'contact_page.dart';

//enum para opções de ordenação.
enum OrderOptions { orderAz, orderZa }

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  ContactHelper helper = ContactHelper();
  List<Contact> contatos = [];

  //carregando a lista de contatos do banco ao iniciar o app
  @override
  void initState() {
    super.initState();
    //then retorna um futuro e coloca em list
    updateList();
  }

  void updateList() {
    helper.getAllContact().then((list) {
      //atualizando a lista de contatos na tela
      setState(() {
        contatos = list.cast<Contact>();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Contatos"),
        backgroundColor: Colors.lightBlue,
        centerTitle: true,
        actions: <Widget>[
          PopupMenuButton<OrderOptions>(
              itemBuilder: (context) => <PopupMenuEntry<OrderOptions>>[]),
        ],
      ),
      backgroundColor: Colors.white,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showContactPage();
        },
        child: Icon(Icons.add),
        backgroundColor: Colors.lightBlue,
      ),
      body: ListView.builder(
          padding: EdgeInsets.all(10.0),
          itemCount: contatos.length,
          itemBuilder: (context, index) {
            return _contatoCard(context, index);
          }),
    );
  }

  /// Função para criação de um card de contato para lista.
  Widget _contatoCard(BuildContext context, int index) {
    return GestureDetector(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(10.0),
            child: Row(
              children: <Widget>[
                Container(
                  width: 80.0,
                  height: 80.0,
                  decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      image: DecorationImage(
                          image: contatos[index].img != ''
                              ? FileImage(File(contatos[index].img))
                              : AssetImage("images/person.png")
                                  as ImageProvider)),
                ),
                Padding(
                  padding: EdgeInsets.only(left: 10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      //se não existe nome, joga vazio
                      Text(
                        contatos[index].name,
                        style: TextStyle(
                            fontSize: 22.0, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        contatos[index].email,
                        style: TextStyle(fontSize: 18.0),
                      ),
                      Text(
                        contatos[index].phone,
                        style: TextStyle(fontSize: 18.0),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        onTap: () {
          _showOptions(context, index);
        });
  }

  //mostra as opções
  void _showOptions(BuildContext context, int index) {
    showModalBottomSheet(
        context: context,
        builder: (context) {
          return BottomSheet(
            //onclose obrigatório. Não fará nada
            onClosing: () {},
            builder: (context) {
              return Container(
                padding: EdgeInsets.all(10.0),
                child: Column(
                  //ocupa o mínimo de espaço.
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Padding(
                        padding: EdgeInsets.all(10.0),
                        child: FlatButton(
                            child: Text("ligar",
                                style: TextStyle(
                                    color: Colors.lightBlue, fontSize: 20.0)),
                            onPressed: () {
                              launch("tel:${contatos[index].phone}");
                              Navigator.pop(context);
                            })),
                    Padding(
                        padding: EdgeInsets.all(10.0),
                        child: FlatButton(
                            child: Text("editar",
                                style: TextStyle(
                                    color: Colors.lightBlue, fontSize: 20.0)),
                            onPressed: () {
                              Navigator.pop(context);
                              _showContactPage(contact: contatos[index]);
                            })),
                    Padding(
                        padding: EdgeInsets.all(10.0),
                        child: FlatButton(
                            child: Text("excluir",
                                style: TextStyle(
                                    color: Colors.lightBlue, fontSize: 20.0)),
                            onPressed: () {
                              helper.deleteContact(contatos[index].id);
                              updateList();
                              Navigator.pop(context);
                            }))
                  ],
                ),
              );
            },
          );
        });
  }

  //mostra o contato. Parâmetro opcional
  void _showContactPage({Contact? contact}) async {
    Contact contatoRet = await Navigator.push(context,
        MaterialPageRoute(builder: (context) => ContactPage(contact: contact)));

    if (contatoRet.id == 0)
      await helper.saveContact(contatoRet);
    else
      await helper.updateContact(contatoRet);

    updateList();
  }
}
