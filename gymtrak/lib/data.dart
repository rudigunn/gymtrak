const complexGroupData = [
  {'date': '2021-10-01', 'name': 'Liam', 'points': 1468},
  {'date': '2021-10-01', 'name': 'Oliver', 'points': 1487},
  {'date': '2021-10-01', 'name': 'Elijah', 'points': 1494},
  {'date': '2021-10-02', 'name': 'Liam', 'points': 1526},
  {'date': '2021-10-02', 'name': 'Noah', 'points': 1492},
  {'date': '2021-10-02', 'name': 'Oliver', 'points': 1470},
  {'date': '2021-10-02', 'name': 'Elijah', 'points': 1477},
  {'date': '2021-10-03', 'name': 'Liam', 'points': 1466},
  {'date': '2021-10-03', 'name': 'Noah', 'points': 1465},
  {'date': '2021-10-03', 'name': 'Oliver', 'points': 1524},
  {'date': '2021-10-03', 'name': 'Elijah', 'points': 1534},
  {'date': '2021-10-04', 'name': 'Noah', 'points': 1504},
  {'date': '2021-10-04', 'name': 'Elijah', 'points': 1524},
  {'date': '2021-10-05', 'name': 'Oliver', 'points': 1534},
  {'date': '2021-10-06', 'name': 'Noah', 'points': 1463},
  {'date': '2021-10-07', 'name': 'Liam', 'points': 1502},
  {'date': '2021-10-07', 'name': 'Noah', 'points': 1539},
  {'date': '2021-10-08', 'name': 'Liam', 'points': 1476},
  {'date': '2021-10-08', 'name': 'Noah', 'points': 1483},
  {'date': '2021-10-08', 'name': 'Oliver', 'points': 1534},
  {'date': '2021-10-08', 'name': 'Elijah', 'points': 1530},
  {'date': '2021-10-09', 'name': 'Noah', 'points': 1519},
  {'date': '2021-10-09', 'name': 'Oliver', 'points': 1497},
  {'date': '2021-10-09', 'name': 'Elijah', 'points': 1460},
  {'date': '2021-10-10', 'name': 'Liam', 'points': 1514},
  {'date': '2021-10-10', 'name': 'Noah', 'points': 1518},
  {'date': '2021-10-10', 'name': 'Oliver', 'points': 1470},
  {'date': '2021-10-10', 'name': 'Elijah', 'points': 1526},
  {'date': '2021-10-11', 'name': 'Liam', 'points': 1517},
  {'date': '2021-10-11', 'name': 'Noah', 'points': 1478},
  {'date': '2021-10-11', 'name': 'Oliver', 'points': 1468},
  {'date': '2021-10-11', 'name': 'Elijah', 'points': 1487},
  {'date': '2021-10-12', 'name': 'Liam', 'points': 1535},
  {'date': '2021-10-12', 'name': 'Noah', 'points': 1537},
  {'date': '2021-10-12', 'name': 'Oliver', 'points': 1463},
  {'date': '2021-10-12', 'name': 'Elijah', 'points': 1478},
  {'date': '2021-10-13', 'name': 'Oliver', 'points': 1524},
  {'date': '2021-10-13', 'name': 'Elijah', 'points': 1496},
  {'date': '2021-10-14', 'name': 'Liam', 'points': 1527},
  {'date': '2021-10-14', 'name': 'Oliver', 'points': 1527},
  {'date': '2021-10-14', 'name': 'Elijah', 'points': 1462},
  {'date': '2021-10-15', 'name': 'Liam', 'points': 1532},
  {'date': '2021-10-15', 'name': 'Noah', 'points': 1509},
  {'date': '2021-10-15', 'name': 'Oliver', 'points': 1540},
  {'date': '2021-10-15', 'name': 'Elijah', 'points': 1536},
  {'date': '2021-10-16', 'name': 'Liam', 'points': 1480},
  {'date': '2021-10-16', 'name': 'Elijah', 'points': 1533},
  {'date': '2021-10-17', 'name': 'Noah', 'points': 1515},
  {'date': '2021-10-17', 'name': 'Oliver', 'points': 1518},
  {'date': '2021-10-17', 'name': 'Elijah', 'points': 1515},
  {'date': '2021-10-18', 'name': 'Oliver', 'points': 1489},
  {'date': '2021-10-18', 'name': 'Elijah', 'points': 1518},
  {'date': '2021-10-19', 'name': 'Oliver', 'points': 1472},
  {'date': '2021-10-19', 'name': 'Elijah', 'points': 1473},
  {'date': '2021-10-20', 'name': 'Liam', 'points': 1513},
  {'date': '2021-10-20', 'name': 'Noah', 'points': 1533},
  {'date': '2021-10-20', 'name': 'Oliver', 'points': 1487},
  {'date': '2021-10-20', 'name': 'Elijah', 'points': 1532},
  {'date': '2021-10-21', 'name': 'Liam', 'points': 1497},
  {'date': '2021-10-21', 'name': 'Noah', 'points': 1477},
  {'date': '2021-10-21', 'name': 'Oliver', 'points': 1516},
  {'date': '2021-10-22', 'name': 'Liam', 'points': 1466},
  {'date': '2021-10-22', 'name': 'Noah', 'points': 1476},
  {'date': '2021-10-22', 'name': 'Oliver', 'points': 1536},
  {'date': '2021-10-22', 'name': 'Elijah', 'points': 1483},
  {'date': '2021-10-23', 'name': 'Liam', 'points': 1503},
  {'date': '2021-10-23', 'name': 'Oliver', 'points': 1521},
  {'date': '2021-10-23', 'name': 'Elijah', 'points': 1529},
  {'date': '2021-10-24', 'name': 'Liam', 'points': 1460},
  {'date': '2021-10-24', 'name': 'Noah', 'points': 1532},
  {'date': '2021-10-24', 'name': 'Oliver', 'points': 1477},
  {'date': '2021-10-24', 'name': 'Elijah', 'points': 1470},
  {'date': '2021-10-25', 'name': 'Noah', 'points': 1504},
  {'date': '2021-10-25', 'name': 'Oliver', 'points': 1494},
  {'date': '2021-10-25', 'name': 'Elijah', 'points': 1528},
  {'date': '2021-10-26', 'name': 'Liam', 'points': 1517},
  {'date': '2021-10-26', 'name': 'Noah', 'points': 1503},
  {'date': '2021-10-26', 'name': 'Elijah', 'points': 1507},
  {'date': '2021-10-27', 'name': 'Liam', 'points': 1538},
  {'date': '2021-10-27', 'name': 'Noah', 'points': 1530},
  {'date': '2021-10-27', 'name': 'Oliver', 'points': 1496},
  {'date': '2021-10-27', 'name': 'Elijah', 'points': 1519},
  {'date': '2021-10-28', 'name': 'Liam', 'points': 1511},
  {'date': '2021-10-28', 'name': 'Oliver', 'points': 1500},
  {'date': '2021-10-28', 'name': 'Elijah', 'points': 1519},
  {'date': '2021-10-29', 'name': 'Noah', 'points': 1499},
  {'date': '2021-10-29', 'name': 'Oliver', 'points': 1489},
  {'date': '2021-10-30', 'name': 'Noah', 'points': 1460}
];

const adjustData = [
  {"type": "Email", "index": 0, "value": 120},
  {"type": "Email", "index": 1, "value": 132},
  {"type": "Email", "index": 2, "value": 101},
  {"type": "Email", "index": 3, "value": 134},
  {"type": "Email", "index": 4, "value": 90},
  {"type": "Email", "index": 5, "value": 230},
  {"type": "Email", "index": 6, "value": 210},
  {"type": "Affiliate", "index": 0, "value": 220},
  {"type": "Affiliate", "index": 1, "value": 182},
  {"type": "Affiliate", "index": 2, "value": 191},
  {"type": "Affiliate", "index": 3, "value": 234},
  {"type": "Affiliate", "index": 4, "value": 290},
  {"type": "Affiliate", "index": 5, "value": 330},
  {"type": "Affiliate", "index": 6, "value": 310},
  {"type": "Video", "index": 0, "value": 150},
  {"type": "Video", "index": 1, "value": 232},
  {"type": "Video", "index": 2, "value": 201},
  {"type": "Video", "index": 3, "value": 154},
  {"type": "Video", "index": 4, "value": 190},
  {"type": "Video", "index": 5, "value": 330},
  {"type": "Video", "index": 6, "value": 410},
  {"type": "Direct", "index": 0, "value": 320},
  {"type": "Direct", "index": 1, "value": 332},
  {"type": "Direct", "index": 2, "value": 301},
  {"type": "Direct", "index": 3, "value": 334},
  {"type": "Direct", "index": 4, "value": 390},
  {"type": "Direct", "index": 5, "value": 330},
  {"type": "Direct", "index": 6, "value": 320},
  {"type": "Search", "index": 0, "value": 320},
  {"type": "Search", "index": 1, "value": 432},
  {"type": "Search", "index": 2, "value": 401},
  {"type": "Search", "index": 3, "value": 434},
  {"type": "Search", "index": 4, "value": 390},
  {"type": "Search", "index": 5, "value": 430},
  {"type": "Search", "index": 6, "value": 420},
];
