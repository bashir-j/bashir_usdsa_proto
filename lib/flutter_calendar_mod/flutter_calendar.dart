import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';
import 'package:usdsa_proto/flutter_calendar_mod/calendar_tile.dart';
import 'date_utils.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';

typedef DayBuilder(BuildContext context, DateTime day);

class Calendar extends StatefulWidget {
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<Tuple2<DateTime, DateTime>> onSelectedRangeChange;
  final bool isExpandable;
  final DayBuilder dayBuilder;
  final bool showChevronsToChangeRange;
  final bool showTodayAction;
  final bool showCalendarPickerIcon;
  final DateTime initialCalendarDateOverride;

  Calendar({
    this.onDateSelected,
    this.onSelectedRangeChange,
    this.isExpandable: true,
    this.dayBuilder,
    this.showTodayAction: true,
    this.showChevronsToChangeRange: true,
    this.showCalendarPickerIcon: true,
    this.initialCalendarDateOverride,
  });

  @override
  _CalendarState createState() => new _CalendarState();

}

class _CalendarState extends State<Calendar> {
  final calendarUtils = new Utils();
  DateTime today = new DateTime.now();
  List<DateTime> selectedMonthsDays;
  Iterable<DateTime> selectedWeeksDays;
  DateTime _selectedDate;
  Tuple2<DateTime, DateTime> selectedRange;
  String currentMonth;
  bool isExpanded = true;
  String displayMonth;
  bool downloadedFlag = false;
  List<Widget> newDayWidgets = [];


  DateTime get selectedDate => _selectedDate;

  void initState() {
    super.initState();
    if(widget.initialCalendarDateOverride != null) today = widget.initialCalendarDateOverride;
    selectedMonthsDays = Utils.daysInMonth(today);
    print(selectedMonthsDays);
    var firstDayOfCurrentWeek = Utils.firstDayOfWeek(today);
    var lastDayOfCurrentWeek = Utils.lastDayOfWeek(today);
    selectedWeeksDays = Utils
        .daysInRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek)
        .toList()
        .sublist(0, 7);
    _selectedDate = today;
    displayMonth = Utils.formatMonth(Utils.firstDayOfWeek(today));
    widget.onDateSelected(_selectedDate);
    AsyncCalendarBuilder();

  }

  Widget get nameAndIconRow {
    var leftInnerIcon;
    var rightInnerIcon;
    var leftOuterIcon;
    var rightOuterIcon;

    if (widget.showCalendarPickerIcon) {
      rightInnerIcon = new IconButton(
        onPressed: () => selectDateFromPicker(),
        icon: new Icon(Icons.calendar_today),
      );
    } else {
      rightInnerIcon = new Container();
    }

    if (widget.showChevronsToChangeRange) {
      leftOuterIcon = new IconButton(
        onPressed: isExpanded ? previousMonth : previousWeek,
        icon: new Icon(Icons.chevron_left),
      );
      rightOuterIcon = new IconButton(
        onPressed: isExpanded ? nextMonth : nextWeek,
        icon: new Icon(Icons.chevron_right),
      );
    } else {
      leftOuterIcon = new Container();
      rightOuterIcon = new Container();
    }

    if (widget.showTodayAction) {
      leftInnerIcon = new InkWell(
        child: new Text('Today'),
        onTap: resetToToday,
      );
    } else {
      leftInnerIcon = new Container();
    }

    return new Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        leftOuterIcon ?? new Container(),
        leftInnerIcon ?? new Container(),
        new Text(
          displayMonth,
          style: new TextStyle(
            fontSize: 20.0,
          ),
        ),
        rightInnerIcon ?? new Container(),
        rightOuterIcon ?? new Container(),
      ],
    );
  }

  Widget get calendarGridView {
    return new Container(
      child: new GestureDetector(
        onHorizontalDragStart: (gestureDetails) => beginSwipe(gestureDetails),
        onHorizontalDragUpdate: (gestureDetails) =>
            getDirection(gestureDetails),
        onHorizontalDragEnd: (gestureDetails) => endSwipe(gestureDetails),
        child: gridviewWidgetBuilder(),
      ),
    );
  }

  Widget gridviewWidgetBuilder(){
    return new GridView.count(
      shrinkWrap: true,
      crossAxisCount: 7,
      childAspectRatio: 1.0,
      mainAxisSpacing: 0.0,
      padding: new EdgeInsets.only(bottom: 0.0),
      children: downloadedFlag ? newSelRebuilder() : calendarBuilder(),
    );
  }
//  Widget asyncGridViewWidgetBuilder(){
//    return FutureBuilder(
//      future: calendarBuilder(),
//      builder: (BuildContext context, AsyncSnapshot snapshot) {
//        print("builder called");
//        return new GridView.count(
//          shrinkWrap: true,
//          crossAxisCount: 7,
//          childAspectRatio: 1.0,
//          mainAxisSpacing: 0.0,
//          padding: new EdgeInsets.only(bottom: 0.0),
//          children: snapshot.data != null ? snapshot.data : <Widget>[] ,
//        );
//      }
//    );
//  }
  List<Widget> newSelRebuilder() {
    List<Widget> tempDays = [];
    Utils.weekdays.forEach(
          (day) {
        tempDays.add(
          new CalendarTile(
            isDayOfWeek: true,
            dayOfWeek: day,
          ),
        );
      },
    );

    for(CalendarTile tile in newDayWidgets){
      if(!tile.isDayOfWeek) {
        tempDays.add(
            new CalendarTile(
              onDateSelected: tile.onDateSelected,
              date: tile.date,
              child: tile.child,
              dateStyles: tile.dateStyles,
              dayOfWeek: tile.dayOfWeek,
              dayOfWeekStyles: tile.dayOfWeekStyles,
              hasEvent: tile.hasEvent,
              isDayOfWeek: tile.isDayOfWeek,
              isSelected: Utils.isSameDay(selectedDate, tile.date),
            )
        );
      }
    }
    setState(() {
      newDayWidgets = tempDays;
    });


    return tempDays;
  }


  List<Widget> calendarBuilder() {

    List<Widget> dayWidgets = [];
    List<DateTime> calendarDays =
    isExpanded ? selectedMonthsDays : selectedWeeksDays;

    Utils.weekdays.forEach(
          (day) {
        dayWidgets.add(
          new CalendarTile(
            isDayOfWeek: true,
            dayOfWeek: day,
          ),
        );
      },
    );

    bool monthStarted = false;
    bool monthEnded = false;

    calendarDays.forEach(
          (day) {
        if (monthStarted && day.day == 01) {
          monthEnded = true;
        }

        if (Utils.isFirstDayOfMonth(day)) {
          monthStarted = true;
        }

        if (this.widget.dayBuilder != null) {
          dayWidgets.add(
            new CalendarTile(
              child: this.widget.dayBuilder(context, day),
            ),
          );
        } else {
          dayWidgets.add(
            new CalendarTile(
              onDateSelected: () => handleSelectedDateAndUserCallback(day),
              date: day,
              dateStyles: configureDateStyle(monthStarted, monthEnded),
              isSelected: Utils.isSameDay(selectedDate, day),
            ),
          );
        }
      },
    );
    return dayWidgets;
  }

  Future<List<Widget>> AsyncCalendarBuilder() async{
    print("downloading");
    newDayWidgets.clear();
    List<DateTime> calendarDays =
        isExpanded ? selectedMonthsDays : selectedWeeksDays;

    Utils.weekdays.forEach(
      (day) {
        newDayWidgets.add(
          new CalendarTile(
            isDayOfWeek: true,
            dayOfWeek: day,
          ),
        );
      },
    );

    bool monthStarted = false;
    bool monthEnded = false;
    bool hasEventTemp = false;
    DocumentSnapshot ds = await Firestore.instance.collection('events').
    document(selectedDate.month.toString() + '-' + selectedDate.year.toString()).get();
    var days = new List<String>.from(ds['days']);
    calendarDays.forEach((day){

      if (monthStarted && day.day == 01) {
        monthEnded = true;
      }

      if (Utils.isFirstDayOfMonth(day)) {
        monthStarted = true;
      }
      hasEventTemp = days.contains(day.day.toString()) && monthStarted;
      if(hasEventTemp){
        days.remove(day.day.toString());
      }

      if (this.widget.dayBuilder != null) {
        newDayWidgets.add(
          new CalendarTile(
            child: this.widget.dayBuilder(context, day),
          ),
        );
      } else {
        print("added");
        newDayWidgets.add(
          new CalendarTile(
            hasEvent: hasEventTemp,
            onDateSelected: () => handleSelectedDateAndUserCallback(day),
            date: day,
            dateStyles: configureDateStyle(monthStarted, monthEnded),
            isSelected: Utils.isSameDay(selectedDate, day),
          ),
        );
      }

    }
    );

//    calendarDays.forEach(
//      (day)  async {
//
//      },
//    );
    print("returned");
    setState(() {
      downloadedFlag = true;
    });

    return newDayWidgets;
  }

  TextStyle configureDateStyle(monthStarted, monthEnded) {
    TextStyle dateStyles;
    if (isExpanded) {
      dateStyles = monthStarted && !monthEnded
          ? new TextStyle(color: Colors.black)
          : new TextStyle(color: Colors.black38);
    } else {
      dateStyles = new TextStyle(color: Colors.black);
    }
    return dateStyles;
  }

  Widget get expansionButtonRow {
    if (widget.isExpandable) {
      return new Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          new Text(Utils.fullDayFormat(selectedDate)),
          new IconButton(
            iconSize: 20.0,
            padding: new EdgeInsets.all(0.0),
            onPressed: toggleExpanded,
            icon: isExpanded
                ? new Icon(Icons.arrow_drop_up)
                : new Icon(Icons.arrow_drop_down),
          ),
        ],
      );
    } else {
      return new Container();
    }
  }

  @override
  Widget build(BuildContext context) {
    return new Container(
      child: new Column(
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          nameAndIconRow,
          new ExpansionCrossFade(
            collapsed: new Text("hi"),
            expanded: calendarGridView,
            isExpanded: isExpanded,
          ),
          expansionButtonRow
        ],
      ),
    );
  }

  void resetToToday() {
    today = new DateTime.now();
    var firstDayOfCurrentMonth = Utils.firstDayOfMonth(today);
    var lastDayOfCurrentMonth = Utils.lastDayOfMonth(today);

    setState(() {
      _selectedDate = today;
      selectedWeeksDays = Utils
          .daysInRange(firstDayOfCurrentMonth, lastDayOfCurrentMonth)
          .toList();
      selectedMonthsDays = Utils.daysInMonth(_selectedDate);
      updateSelectedRange(firstDayOfCurrentMonth, lastDayOfCurrentMonth);
      displayMonth = Utils.formatMonth(Utils.firstDayOfMonth(today));
      downloadedFlag = false;
    });
    AsyncCalendarBuilder();
    _launchDateSelectionCallback(today);
  }

  void nextMonth() {
    setState(() {
      today = Utils.nextMonth(today);
      var firstDateOfNewMonth = Utils.firstDayOfMonth(today);
      var lastDateOfNewMonth = Utils.lastDayOfMonth(today);
      updateSelectedRange(firstDateOfNewMonth, lastDateOfNewMonth);
      selectedMonthsDays = Utils.daysInMonth(today);
      _selectedDate = firstDateOfNewMonth;
      displayMonth = Utils.formatMonth(Utils.firstDayOfMonth(today));
      downloadedFlag = false;
    });
    AsyncCalendarBuilder();
    _launchDateSelectionCallback(today);

  }

  void previousMonth() {
    setState(() {
      today = Utils.previousMonth(today);
      var firstDateOfNewMonth = Utils.firstDayOfMonth(today);
      var lastDateOfNewMonth = Utils.lastDayOfMonth(today);
      updateSelectedRange(firstDateOfNewMonth, lastDateOfNewMonth);
      selectedMonthsDays = Utils.daysInMonth(today);
      _selectedDate = firstDateOfNewMonth;
      displayMonth = Utils.formatMonth(Utils.firstDayOfMonth(today));
      downloadedFlag = false;
    });
    _launchDateSelectionCallback(today);
    AsyncCalendarBuilder();

  }

  void nextWeek() {
    setState(() {
      today = Utils.nextWeek(today);
      var firstDayOfCurrentWeek = Utils.firstDayOfWeek(today);
      var lastDayOfCurrentWeek = Utils.lastDayOfWeek(today);
      updateSelectedRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek);
      selectedWeeksDays = Utils
          .daysInRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek)
          .toList()
          .sublist(0, 7);
      displayMonth = Utils.formatMonth(Utils.firstDayOfWeek(today));
    });
  }

  void previousWeek() {
    setState(() {
      today = Utils.previousWeek(today);
      var firstDayOfCurrentWeek = Utils.firstDayOfWeek(today);
      var lastDayOfCurrentWeek = Utils.lastDayOfWeek(today);
      updateSelectedRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek);
      selectedWeeksDays = Utils
          .daysInRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek)
          .toList()
          .sublist(0, 7);
      displayMonth = Utils.formatMonth(Utils.firstDayOfWeek(today));
    });
  }

  void updateSelectedRange(DateTime start, DateTime end) {
    selectedRange = new Tuple2<DateTime, DateTime>(start, end);
    if (widget.onSelectedRangeChange != null) {
      widget.onSelectedRangeChange(selectedRange);
    }
  }

  Future<Null> selectDateFromPicker() async {

    DateTime selected;
    final ios = Theme.of(context).platform == TargetPlatform.iOS;
    if (!ios) {
      selected = await showDatePicker(
        context: context,
        initialDate: _selectedDate ?? new DateTime.now(),
        firstDate: new DateTime(1960),
        lastDate: new DateTime(2050),
      );
    }else if(ios){
      DatePicker.showDatePicker(
        context,
        minYear: 1970,
        maxYear: 2070,
        initialYear: today.year,
        initialMonth: today.month,
        initialDate: today.day,
        onChanged: (year, month, date) {
          print('onChanged date: $year-$month-$date');
        },
        onConfirm: (year, month, date) {
          setState(() {
            selected = new DateTime.utc(year,month,date);
            _selectedDate = selected;
            var firstDayOfCurrentWeek = Utils.firstDayOfWeek(selected);
            var lastDayOfCurrentWeek = Utils.lastDayOfWeek(selected);
            selectedWeeksDays = Utils
                .daysInRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek)
                .toList();
            selectedMonthsDays = Utils.daysInMonth(selected);
            displayMonth = Utils.formatMonth(Utils.firstDayOfMonth(selected));
            downloadedFlag = false;
            AsyncCalendarBuilder();
            _launchDateSelectionCallback(selected);
          });
        },
      );
    }

    if (selected != null) {
      var firstDayOfCurrentWeek = Utils.firstDayOfWeek(selected);
      var lastDayOfCurrentWeek = Utils.lastDayOfWeek(selected);

      setState(() {
        _selectedDate = selected;
        selectedWeeksDays = Utils
            .daysInRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek)
            .toList();
        selectedMonthsDays = Utils.daysInMonth(selected);
        displayMonth = Utils.formatMonth(Utils.firstDayOfMonth(selected));
        downloadedFlag = false;
      });
      AsyncCalendarBuilder();

      _launchDateSelectionCallback(selected);
    }
  }

  var gestureStart;
  var gestureDirection;
  void beginSwipe(DragStartDetails gestureDetails) {
    gestureStart = gestureDetails.globalPosition.dx;
  }

  void getDirection(DragUpdateDetails gestureDetails) {
    if (gestureDetails.globalPosition.dx < gestureStart) {
      gestureDirection = 'rightToLeft';
    } else {
      gestureDirection = 'leftToRight';
    }
  }

  void endSwipe(DragEndDetails gestureDetails) {
    if (gestureDirection == 'rightToLeft') {
      if (isExpanded) {
        nextMonth();
      } else {
        nextWeek();
      }
    } else {
      if (isExpanded) {
        previousMonth();
      } else {
        previousWeek();
      }
    }
  }

  void toggleExpanded() {
    if (widget.isExpandable) {
      setState(() => isExpanded = !isExpanded);
    }
  }

  void handleSelectedDateAndUserCallback(DateTime day) {
    var firstDayOfCurrentWeek = Utils.firstDayOfWeek(day);
    var lastDayOfCurrentWeek = Utils.lastDayOfWeek(day);
    setState(() {
      _selectedDate = day;
      selectedWeeksDays = Utils
          .daysInRange(firstDayOfCurrentWeek, lastDayOfCurrentWeek)
          .toList();
      selectedMonthsDays = Utils.daysInMonth(day);
      displayMonth = Utils.formatMonth(Utils.firstDayOfMonth(day));

    });
    _launchDateSelectionCallback(day);
  }

  void _launchDateSelectionCallback(DateTime day) {
    if (widget.onDateSelected != null) {
      widget.onDateSelected(day);
    }
  }
}

class ExpansionCrossFade extends StatelessWidget {
  final Widget collapsed;
  final Widget expanded;
  final bool isExpanded;

  ExpansionCrossFade({this.collapsed, this.expanded, this.isExpanded});

  @override
  Widget build(BuildContext context) {
    return new Flexible(
      flex: 1,
      child: new AnimatedCrossFade(
        firstChild: collapsed,
        secondChild: expanded,
        firstCurve: const Interval(0.0, 1.0, curve: Curves.fastOutSlowIn),
        secondCurve: const Interval(0.0, 1.0, curve: Curves.fastOutSlowIn),
        sizeCurve: Curves.decelerate,
        crossFadeState:
            isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
        duration: const Duration(milliseconds: 300),
      ),
    );
  }
}
