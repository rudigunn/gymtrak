import 'package:gymtrak/utilities/bloodwork/bloodwork_category.dart';
import 'package:gymtrak/utilities/bloodwork/bloodwork_parameter.dart';

List<BloodWorkParameter> parametersInitial = [
  BloodWorkParameter(
      name: 'AT III',
      fullName: 'Anti Thrombin III',
      category: Category.getName(ParameterCategory.heart),
      upperLimit: 100,
      lowerLimit: 0,
      unit: '%'),
  BloodWorkParameter(
      name: 'Cholesterin',
      fullName: 'Cholesterin',
      category: Category.getName(ParameterCategory.heart),
      upperLimit: 200,
      lowerLimit: 0,
      unit: 'mg/dl'),
  BloodWorkParameter(
      name: 'Erythrozyten',
      fullName: 'Ery',
      category: Category.getName(ParameterCategory.blood),
      upperLimit: 4.6,
      lowerLimit: 6.2,
      unit: ' /pl'),
  BloodWorkParameter(
      name: 'GFR',
      fullName: 'Gromeruläre Filtrationsrate',
      category: Category.getName(ParameterCategory.kidney),
      upperLimit: 130,
      lowerLimit: 100,
      unit: 'ml/min'),
  BloodWorkParameter(
      name: 'Albumin',
      fullName: 'Alb',
      category: Category.getName(ParameterCategory.liver),
      upperLimit: 50,
      lowerLimit: 36,
      unit: 'g/l'),
  BloodWorkParameter(
      name: 'Calcium',
      fullName: 'Ca',
      category: Category.getName(ParameterCategory.electrolytes),
      upperLimit: 2.10,
      lowerLimit: 2.50,
      unit: 'mmol/l'),
  BloodWorkParameter(
      name: 'Eisen',
      fullName: 'Fe',
      category: Category.getName(ParameterCategory.vitaminesAndTraceElements),
      upperLimit: 7.20,
      lowerLimit: 21.50,
      unit: 'µmol/l'),
];
