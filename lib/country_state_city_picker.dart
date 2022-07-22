library country_state_city_picker_nona;

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;

import 'model/select_status_model.dart' as StatusModel;

class EditProfileDropdown extends StatelessWidget {
  final String label;
  final Widget? suffixIcon;
  final String? initialValue;
  final bool? readOnly;
  final bool? enabled;
  final VoidCallback? onTap;
  final Function(String)? onChanged;
  final TextEditingController? controller;
  final DropdownButton<String>? child;
  const EditProfileDropdown({
    Key? key,
    required this.label,
    this.initialValue,
    this.readOnly,
    this.enabled,
    this.onTap,
    this.controller,
    this.onChanged,
    this.suffixIcon,
    this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Color(0xFF7985A0),
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(
          height: 4,
        ),
        InkWell(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Color(0xFFD9DFEB),
              ),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Row(
              children: [
                Expanded(
                  child: IgnorePointer(
                    ignoring: onTap != null,
                    child: child,
                  ),
                ),
                if (suffixIcon != null)
                  Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: suffixIcon!,
                  ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class SelectState extends StatefulWidget {
  final ValueChanged<String> onCountryChanged;
  final ValueChanged<String> onStateChanged;
  final ValueChanged<String> onCityChanged;
  final String? preselectedCountry;
  final String? preselectedState;
  final String? preselectedCity;
  final VoidCallback? onCountryTap;
  final VoidCallback? onStateTap;
  final VoidCallback? onCityTap;
  final TextStyle? style;
  final Color? dropdownColor;
  final InputDecoration decoration;
  final double spacing;

  const SelectState(
      {Key? key,
      required this.preselectedCountry,
      required this.preselectedState,
      required this.preselectedCity,
      required this.onCountryChanged,
      required this.onStateChanged,
      required this.onCityChanged,
      this.decoration =
          const InputDecoration(contentPadding: EdgeInsets.all(0.0)),
      this.spacing = 0.0,
      this.style,
      this.dropdownColor,
      this.onCountryTap,
      this.onStateTap,
      this.onCityTap})
      : super(key: key);

  @override
  _SelectStateState createState() => _SelectStateState();
}

class _SelectStateState extends State<SelectState> {
  List<String> _country = ["Choose Country"];
  List<String> _states = ["Choose State/Province"];
  List<String> _cities = ["Choose City"];
  String _selectedCountry = "Choose Country";
  String _selectedState = "Choose State/Province";
  String _selectedCity = "Choose City";
  var responses;

  @override
  void initState() {
    getCounty();
    super.initState();
  }

  Future getResponse() async {
    var res = await rootBundle.loadString(
        'packages/country_state_city_picker/lib/assets/country.json');
    return jsonDecode(res);
  }

  Future getCounty() async {
    var countryres = await getResponse() as List;
    countryres.forEach((data) {
      var model = StatusModel.StatusModel();
      model.name = data['name'];
      model.emoji = data['emoji'];
      if (!mounted) return;
      setState(() {
        _country.add(model.emoji! + "    " + model.name!);
      });
    });

    return _country;
  }

  Future getState() async {
    var response = await getResponse();
    var takestate = response
        .map((map) => StatusModel.StatusModel.fromJson(map))
        .where((item) => item.emoji + "    " + item.name == _selectedCountry)
        .map((item) => item.state)
        .toList();
    var states = takestate as List;
    states.forEach((f) {
      if (!mounted) return;
      setState(() {
        var name = f.map((item) => item.name).toList();
        for (var statename in name) {
          print(statename.toString());

          _states.add(statename.toString());
        }
      });
    });

    return _states;
  }

  Future getCity() async {
    var response = await getResponse();
    var takestate = response
        .map((map) => StatusModel.StatusModel.fromJson(map))
        .where((item) => item.emoji + "    " + item.name == _selectedCountry)
        .map((item) => item.state)
        .toList();
    var states = takestate as List;
    states.forEach((f) {
      var name = f.where((item) => item.name == _selectedState);
      var cityname = name.map((item) => item.city).toList();
      cityname.forEach((ci) {
        if (!mounted) return;
        setState(() {
          var citiesname = ci.map((item) => item.name).toList();
          for (var citynames in citiesname) {
            print(citynames.toString());

            _cities.add(citynames.toString());
          }
        });
      });
    });
    return _cities;
  }

  void _onSelectedCountry(String value) {
    if (!mounted) return;
    setState(() {
      _selectedState = "Choose  State/Province";
      _states = ["Choose  State/Province"];
      _selectedCountry = value;
      this.widget.onCountryChanged(value);
      getState();
    });
  }

  void _onSelectedState(String value) {
    if (!mounted) return;
    setState(() {
      _selectedCity = "Choose City";
      _cities = ["Choose City"];
      _selectedState = value;
      this.widget.onStateChanged(value);
      getCity();
    });
  }

  void _onSelectedCity(String value) {
    if (!mounted) return;
    setState(() {
      _selectedCity = value;
      this.widget.onCityChanged(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        EditProfileDropdown(
          label: 'Country',
          enabled: false,
          initialValue: widget.preselectedCountry ?? "Choose Country",
          child: DropdownButton<String>(
            underline: Container(),
            dropdownColor: widget.dropdownColor,
            isExpanded: true,
            items: _country.map(
              (String dropDownStringItem) {
                return DropdownMenuItem<String>(
                  value: dropDownStringItem,
                  child: Row(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: Text(
                          dropDownStringItem,
                          style: widget.style,
                        ),
                      )
                    ],
                  ),
                );
              },
            ).toList(),
            onChanged: (value) => _onSelectedCountry(value!),
            value: _selectedCountry,
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        EditProfileDropdown(
          label: 'State',
          enabled: false,
          initialValue: widget.preselectedState ?? "Choose State/Province",
          child: DropdownButton<String>(
            underline: Container(),
            dropdownColor: widget.dropdownColor,
            isExpanded: true,
            items: _states.map((String dropDownStringItem) {
              return DropdownMenuItem<String>(
                value: dropDownStringItem,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(dropDownStringItem, style: widget.style),
                ),
              );
            }).toList(),
            onChanged: (value) => _onSelectedState(value!),
            value: _selectedState,
          ),
        ),
        const SizedBox(
          height: 20,
        ),
        EditProfileDropdown(
          label: 'City',
          enabled: false,
          initialValue: widget.preselectedCity ?? "Choose City",
          child: DropdownButton<String>(
            underline: Container(),
            dropdownColor: widget.dropdownColor,
            isExpanded: true,
            items: _cities.map((String dropDownStringItem) {
              return DropdownMenuItem<String>(
                value: dropDownStringItem,
                child: Padding(
                  padding: const EdgeInsets.only(left: 8.0),
                  child: Text(dropDownStringItem, style: widget.style),
                ),
              );
            }).toList(),
            onChanged: (value) => _onSelectedCity(value!),
            value: _selectedCity,
          ),
        ),
      ],
    );
  }
}
