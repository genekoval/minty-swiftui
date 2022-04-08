protocol StorableEntity: AnyObject & Identifiable {
    associatedtype Preview: Identifiable where Preview.ID == Self.ID

    init(id: Self.ID, storage: StateMap<Self>?)

    func load(from preview: Preview)
}

struct EntityStore<Entity> where Entity: StorableEntity {
    private let entities = StateMap<Entity>()

    func fetch(id: Entity.ID) -> Entity {
        if let entity = entities[id] {
            return entity
        }

        let entity = Entity(id: id, storage: entities)
        entities[id] = entity
        return entity
    }

    func fetch(for preview: Entity.Preview) -> Entity {
        let entity = fetch(id: preview.id)
        entity.load(from: preview)
        return entity
    }
}
