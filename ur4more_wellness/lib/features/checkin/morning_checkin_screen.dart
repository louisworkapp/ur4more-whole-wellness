import 'package:flutter/material.dart';
import '../../design/mind_tokens.dart';

class MorningCheckInScreen extends StatefulWidget {
  const MorningCheckInScreen({super.key});
  @override State<MorningCheckInScreen> createState()=>_MorningCheckInScreenState();
}

class _MorningCheckInScreenState extends State<MorningCheckInScreen>{
  int page=0; final ctrl = PageController();
  int mood=6, energy=5, urge=3;
  bool focusMind=true, focusBody=true, focusSpirit=false;

  void _next(){ setState(()=>page++); ctrl.jumpToPage(page); }

  @override Widget build(BuildContext context){
    return Theme(
      data: buildMindTheme(Theme.of(context)),
      child: Scaffold(
        appBar: AppBar(title: const Text('Morning Check-In')),
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 430),
            child: PageView(
              controller: ctrl,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _card('Your pulse', Column(children:[
                  _slider('Mood', mood, (v)=>setState(()=>mood=v)),
                  _slider('Energy', energy, (v)=>setState(()=>energy=v)),
                  _slider('Urge/Stress', urge, (v)=>setState(()=>urge=v)),
                ]), onNext: _next),
                _card('Choose today\'s focus', Column(children:[
                  _toggle('Mind', focusMind, (v)=>setState(()=>focusMind=v)),
                  const SizedBox(height:8),
                  _toggle('Body', focusBody, (v)=>setState(()=>focusBody=v)),
                  const SizedBox(height:8),
                  _toggle('Spirit', focusSpirit, (v)=>setState(()=>focusSpirit=v)),
                ]), onNext: _next),
                _card('Coach suggestions', const Text('TODO: suggest blocks from coaches'), onNext: _next),
                _card('Calendar preview', const Text('TODO: preview today\'s blocks'), onNext: _next),
                _card('Commit', const Text('TODO: Save & schedule'), onNext: ()=>Navigator.pop(context)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _card(String title, Widget child, {required VoidCallback onNext}){
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: MindColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: MindColors.outline),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontSize:20, fontWeight: FontWeight.w700)),
          const SizedBox(height:12),
          child,
          const SizedBox(height:16),
          SizedBox(width: double.infinity, child: ElevatedButton(onPressed: onNext, child: const Text('Next'))),
        ]),
      ),
    );
  }

  Widget _slider(String label, int value, ValueChanged<int> onChanged){
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
      Slider(min:1, max:10, divisions:9, value:value.toDouble(), onChanged:(v)=>onChanged(v.round())),
      const SizedBox(height:8),
    ]);
  }

  Widget _toggle(String label, bool value, ValueChanged<bool> onChanged){
    return Container(
      decoration: BoxDecoration(
        color: value? MindColors.surfaceHover : MindColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: value? MindColors.brandBlue : MindColors.outline),
      ),
      child: SwitchListTile(title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)), value: value, onChanged: onChanged),
    );
  }
}
