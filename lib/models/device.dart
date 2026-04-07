class Device {
  final String id;
  final String name;
  final String type;
  final String brand;
  final String model;
  final String location;
  final String assignedTo;
  final String status;
  final String notes;
  final String? imageUrl;

  Device({
    required this.id,
    required this.name,
    required this.type,
    required this.brand,
    required this.model,
    required this.location,
    required this.assignedTo,
    required this.status,
    required this.notes,
    this.imageUrl,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'type': type,
    'brand': brand,
    'model': model,
    'location': location,
    'assignedTo': assignedTo,
    'status': status,
    'notes': notes,
    'imageUrl': imageUrl,
  };

  factory Device.fromJson(Map<String, dynamic> json) {
    return Device(
      id: json['id'] as String? ?? '',
      name: (json['name'] ?? '') as String,
      type: (json['type'] ?? '') as String,
      brand: (json['brand'] ?? '') as String,
      model: (json['model'] ?? '') as String,
      location: (json['location'] ?? '') as String,
      assignedTo: (json['assignedTo'] ?? '') as String,
      status: (json['status'] ?? 'Good') as String,
      notes: (json['notes'] ?? '') as String,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}
