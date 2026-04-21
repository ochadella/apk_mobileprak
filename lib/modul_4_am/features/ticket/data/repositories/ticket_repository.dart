import '../../../../core/network/api_service.dart';

class TicketRepository {
  final ApiService api = ApiService();

  Future<List<dynamic>> getTickets() async {
    return await api.getTickets();
  }
}