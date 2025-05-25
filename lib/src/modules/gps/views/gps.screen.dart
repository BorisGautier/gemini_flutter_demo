import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:kartia/generated/l10n.dart';
import 'package:kartia/src/core/utils/colors.util.dart';
import 'package:kartia/src/modules/gps/bloc/gps_bloc.dart';

class GpsScreen extends StatelessWidget {
  const GpsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: BlocBuilder<GpsBloc, GpsState>(
          builder: (context, state) {
            return !state.isGpsEnabled
                ? const _EnableGpsMessage()
                : const _AccessBotton();
          },
        ),
      ),
    );
  }
}

class _AccessBotton extends StatelessWidget {
  const _AccessBotton();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          KartiaLocalizations.of(context).gpsAccess,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontFamily: "OpenSans-Bold"),
        ),
        const Divider(height: 50, color: Colors.transparent),
        MaterialButton(
          color: AppColors.primary,
          splashColor: Colors.transparent,
          shape: const StadiumBorder(),
          elevation: 0,
          onPressed: () {
            final gpsBloc = BlocProvider.of<GpsBloc>(context);
            gpsBloc.askGpsAccess();
          },
          child: Text(
            KartiaLocalizations.of(context).askAccess,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.white),
          ),
        ),
      ],
    );
  }
}

class _EnableGpsMessage extends StatelessWidget {
  const _EnableGpsMessage();

  @override
  Widget build(BuildContext context) {
    return Text(
      KartiaLocalizations.of(context).enableGps,
      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
        fontSize: 25,
        fontWeight: FontWeight.w300,
      ),
    );
  }
}
