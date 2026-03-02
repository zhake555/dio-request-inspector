import 'package:flutter/material.dart';
import 'package:dio_request_inspector/src/common/helpers.dart';
import 'package:dio_request_inspector/src/model/http_activity.dart';
import 'package:dio_request_inspector/src/page/dashboard/widget/dot_indicator_widget.dart';

class ItemResponseWidget extends StatelessWidget {
  final HttpActivity data;

  const ItemResponseWidget({Key? key, required this.data}) : super(key: key);

  static const _methodColors = {
    'GET': Color(0xFF2196F3),
    'POST': Color(0xFF4CAF50),
    'PUT': Color(0xFFFF9800),
    'PATCH': Color(0xFF9C27B0),
    'DELETE': Color(0xFFF44336),
  };

  Color get _methodColor =>
      _methodColors[data.method.toUpperCase()] ?? const Color(0xFF607D8B);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFEEEEEE)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTopRow(),
            const SizedBox(height: 4),
            _buildServerRow(),
            _buildPayloadSection(),
            const SizedBox(height: 6),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildTopRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _MethodBadge(method: data.method, color: _methodColor),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            data.endpoint,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A1A),
              height: 1.3,
            ),
          ),
        ),
        const SizedBox(width: 8),
        _buildStatusBadge(),
      ],
    );
  }

  Widget _buildServerRow() {
    if (data.server.isEmpty) return const SizedBox.shrink();
    return Text(
      data.server,
      style: const TextStyle(
        fontSize: 13,
        color: Color(0xFF9E9E9E),
      ),
    );
  }

  Widget _buildPayloadSection() {
    final queryParams = data.request?.queryParameters;
    final hasQuery = queryParams != null && queryParams.isNotEmpty;
    final body = data.request?.body;
    final hasBody = body != null && body.isNotEmpty;

    if (!hasQuery && !hasBody) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Divider(height: 1, color: Color(0xFFF0F0F0)),
          const SizedBox(height: 6),
          if (hasQuery)
            _PayloadRow(
              label: 'Query',
              value: _formatQueryParams(queryParams),
              color: const Color(0xFF1976D2),
            ),
          if (hasQuery && hasBody) const SizedBox(height: 2),
          if (hasBody)
            _PayloadRow(
              label: 'Body',
              value: body,
              color: const Color(0xFF388E3C),
            ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F8F8),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        children: [
          const Icon(Icons.access_time, size: 13, color: Color(0xFFBDBDBD)),
          const SizedBox(width: 4),
          Text(
            data.request?.time != null
                ? _formatTime(data.request!.time)
                : 'n/a',
            style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
          ),
          const Spacer(),
          const Icon(Icons.swap_vert, size: 13, color: Color(0xFFBDBDBD)),
          const SizedBox(width: 3),
          Text(
            '${Helper.formatBytes(data.request?.size ?? 0)} / ${Helper.formatBytes(data.response?.size ?? 0)}',
            style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
          ),
          const Spacer(),
          const Icon(Icons.timer_outlined, size: 13, color: Color(0xFFBDBDBD)),
          const SizedBox(width: 3),
          Text(
            Helper.formatTime(data.duration),
            style: const TextStyle(fontSize: 12, color: Color(0xFF9E9E9E)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge() {
    final int code = data.response?.status ?? 0;

    if (code == 0) {
      return const DotIndicatorWidget(
        dotColor: Color(0xFFBDBDBD),
        dotSize: 7.0,
        animationDuration: Duration(milliseconds: 900),
      );
    }

    Color bg;
    Color fg;
    if (code >= 200 && code < 300) {
      bg = const Color(0xFFE8F5E9);
      fg = const Color(0xFF2E7D32);
    } else if (code >= 300 && code < 400) {
      bg = const Color(0xFFE3F2FD);
      fg = const Color(0xFF1565C0);
    } else if (code >= 400 && code < 500) {
      bg = const Color(0xFFFFF3E0);
      fg = const Color(0xFFE65100);
    } else {
      bg = const Color(0xFFFFEBEE);
      fg = const Color(0xFFC62828);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        code.toString(),
        style: TextStyle(
          color: fg,
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  String _formatQueryParams(Map<String, dynamic> params) =>
      params.entries.map((e) => '${e.key}=${e.value}').join(' · ');

  String _formatTime(DateTime time) =>
      '${_pad(time.hour)}:${_pad(time.minute)}:${_pad(time.second)}';

  String _pad(int v) => v.toString().padLeft(2, '0');
}

class _MethodBadge extends StatelessWidget {
  final String method;
  final Color color;

  const _MethodBadge({required this.method, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(5),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Text(
        method.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}

class _PayloadRow extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _PayloadRow({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.3,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF616161),
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }
}
