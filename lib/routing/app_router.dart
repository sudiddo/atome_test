import 'package:go_router/go_router.dart';
import '../features/pets/presentation/pages/pets_list_page.dart';
import '../features/pets/presentation/pages/pet_detail_page.dart';

final GoRouter appRouter = GoRouter(
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const PetsListPage(),
    ),
    GoRoute(
      path: '/pets/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return PetDetailPage(petId: id);
      },
    ),
  ],
);