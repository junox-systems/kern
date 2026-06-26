class CreateCommitmentDependencies < ActiveRecord::Migration[8.1]
  def change
    create_table :commitment_dependencies, id: :uuid do |t|
      t.references :commitment, null: false, foreign_key: true, type: :uuid
      t.references :depends_on, null: false, type: :uuid, foreign_key: { to_table: :commitments }

      t.timestamps
    end

    add_index :commitment_dependencies, [:commitment_id, :depends_on_id], unique: true, name: "index_commitment_deps_on_commitment_and_depends_on"
  end
end
