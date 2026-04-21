import '../../data/repositories/ticket_repository.dart';

class GetTickets {
  final TicketRepository repository;

  GetTickets(this.repository);

  Future<List<dynamic>> execute() async {
    return await repository.getTickets();
  }
}