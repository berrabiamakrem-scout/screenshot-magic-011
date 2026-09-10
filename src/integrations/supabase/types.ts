export type Json =
  | string
  | number
  | boolean
  | null
  | { [key: string]: Json | undefined }
  | Json[]

export type Database = {
  // Allows to automatically instantiate createClient with right options
  // instead of createClient<Database, { PostgrestVersion: 'XX' }>(URL, KEY)
  __InternalSupabase: {
    PostgrestVersion: "14.5"
  }
  public: {
    Tables: {
      data_catalog: {
        Row: {
          category: string
          code: string
          created_at: string
          description_ar: string | null
          id: string
          name_ar: string
          unit_of_measure: string | null
          updated_at: string
        }
        Insert: {
          category: string
          code: string
          created_at?: string
          description_ar?: string | null
          id?: string
          name_ar: string
          unit_of_measure?: string | null
          updated_at?: string
        }
        Update: {
          category?: string
          code?: string
          created_at?: string
          description_ar?: string | null
          id?: string
          name_ar?: string
          unit_of_measure?: string | null
          updated_at?: string
        }
        Relationships: []
      }
      org_unit_closure: {
        Row: {
          ancestor_id: string
          depth: number
          unit_id: string
        }
        Insert: {
          ancestor_id: string
          depth: number
          unit_id: string
        }
        Update: {
          ancestor_id?: string
          depth?: number
          unit_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "org_unit_closure_ancestor_id_fkey"
            columns: ["ancestor_id"]
            isOneToOne: false
            referencedRelation: "org_units"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "org_unit_closure_unit_id_fkey"
            columns: ["unit_id"]
            isOneToOne: false
            referencedRelation: "org_units"
            referencedColumns: ["id"]
          },
        ]
      }
      org_units: {
        Row: {
          active: boolean
          archived_at: string | null
          code: string | null
          created_at: string
          governorate: string | null
          id: string
          latitude: number | null
          level: Database["public"]["Enums"]["org_level"]
          longitude: number | null
          name_ar: string
          name_fr: string | null
          parent_id: string | null
          region_code: string | null
          updated_at: string
        }
        Insert: {
          active?: boolean
          archived_at?: string | null
          code?: string | null
          created_at?: string
          governorate?: string | null
          id?: string
          latitude?: number | null
          level: Database["public"]["Enums"]["org_level"]
          longitude?: number | null
          name_ar: string
          name_fr?: string | null
          parent_id?: string | null
          region_code?: string | null
          updated_at?: string
        }
        Update: {
          active?: boolean
          archived_at?: string | null
          code?: string | null
          created_at?: string
          governorate?: string | null
          id?: string
          latitude?: number | null
          level?: Database["public"]["Enums"]["org_level"]
          longitude?: number | null
          name_ar?: string
          name_fr?: string | null
          parent_id?: string | null
          region_code?: string | null
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "org_units_parent_id_fkey"
            columns: ["parent_id"]
            isOneToOne: false
            referencedRelation: "org_units"
            referencedColumns: ["id"]
          },
        ]
      }
      phase_objectives: {
        Row: {
          code: string
          created_at: string
          description_ar: string | null
          id: string
          phase_id: string
          status: Database["public"]["Enums"]["record_status"]
          strategic_objective_id: string
          supersedes_id: string | null
          title_ar: string
          updated_at: string
          version: number
        }
        Insert: {
          code: string
          created_at?: string
          description_ar?: string | null
          id?: string
          phase_id: string
          status?: Database["public"]["Enums"]["record_status"]
          strategic_objective_id: string
          supersedes_id?: string | null
          title_ar: string
          updated_at?: string
          version?: number
        }
        Update: {
          code?: string
          created_at?: string
          description_ar?: string | null
          id?: string
          phase_id?: string
          status?: Database["public"]["Enums"]["record_status"]
          strategic_objective_id?: string
          supersedes_id?: string | null
          title_ar?: string
          updated_at?: string
          version?: number
        }
        Relationships: [
          {
            foreignKeyName: "phase_objectives_phase_id_fkey"
            columns: ["phase_id"]
            isOneToOne: false
            referencedRelation: "strategy_phases"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "phase_objectives_strategic_objective_id_fkey"
            columns: ["strategic_objective_id"]
            isOneToOne: false
            referencedRelation: "strategic_objectives"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "phase_objectives_supersedes_id_fkey"
            columns: ["supersedes_id"]
            isOneToOne: false
            referencedRelation: "phase_objectives"
            referencedColumns: ["id"]
          },
        ]
      }
      priorities: {
        Row: {
          code: string | null
          created_at: string
          description_ar: string | null
          id: string
          number: number
          path_id: string
          title_ar: string
          updated_at: string
        }
        Insert: {
          code?: string | null
          created_at?: string
          description_ar?: string | null
          id?: string
          number: number
          path_id: string
          title_ar: string
          updated_at?: string
        }
        Update: {
          code?: string | null
          created_at?: string
          description_ar?: string | null
          id?: string
          number?: number
          path_id?: string
          title_ar?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "priorities_path_id_fkey"
            columns: ["path_id"]
            isOneToOne: false
            referencedRelation: "strategic_paths"
            referencedColumns: ["id"]
          },
        ]
      }
      profiles: {
        Row: {
          active: boolean
          created_at: string
          full_name: string | null
          id: string
          org_unit_id: string | null
          phone: string | null
          updated_at: string
        }
        Insert: {
          active?: boolean
          created_at?: string
          full_name?: string | null
          id: string
          org_unit_id?: string | null
          phone?: string | null
          updated_at?: string
        }
        Update: {
          active?: boolean
          created_at?: string
          full_name?: string | null
          id?: string
          org_unit_id?: string | null
          phone?: string | null
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "profiles_org_unit_id_fkey"
            columns: ["org_unit_id"]
            isOneToOne: false
            referencedRelation: "org_units"
            referencedColumns: ["id"]
          },
        ]
      }
      reference_data: {
        Row: {
          breakdown: Json
          catalog_id: string
          created_at: string
          created_by: string | null
          data_owner: string | null
          id: string
          notes: string | null
          org_unit_id: string
          season_id: string | null
          source: string | null
          status: Database["public"]["Enums"]["validation_status"]
          unit_of_measure: string | null
          updated_at: string
          validated_at: string | null
          validated_by: string | null
          value_numeric: number | null
          value_text: string | null
          year: number | null
        }
        Insert: {
          breakdown?: Json
          catalog_id: string
          created_at?: string
          created_by?: string | null
          data_owner?: string | null
          id?: string
          notes?: string | null
          org_unit_id: string
          season_id?: string | null
          source?: string | null
          status?: Database["public"]["Enums"]["validation_status"]
          unit_of_measure?: string | null
          updated_at?: string
          validated_at?: string | null
          validated_by?: string | null
          value_numeric?: number | null
          value_text?: string | null
          year?: number | null
        }
        Update: {
          breakdown?: Json
          catalog_id?: string
          created_at?: string
          created_by?: string | null
          data_owner?: string | null
          id?: string
          notes?: string | null
          org_unit_id?: string
          season_id?: string | null
          source?: string | null
          status?: Database["public"]["Enums"]["validation_status"]
          unit_of_measure?: string | null
          updated_at?: string
          validated_at?: string | null
          validated_by?: string | null
          value_numeric?: number | null
          value_text?: string | null
          year?: number | null
        }
        Relationships: [
          {
            foreignKeyName: "reference_data_catalog_id_fkey"
            columns: ["catalog_id"]
            isOneToOne: false
            referencedRelation: "data_catalog"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "reference_data_org_unit_id_fkey"
            columns: ["org_unit_id"]
            isOneToOne: false
            referencedRelation: "org_units"
            referencedColumns: ["id"]
          },
          {
            foreignKeyName: "reference_data_season_id_fkey"
            columns: ["season_id"]
            isOneToOne: false
            referencedRelation: "seasons"
            referencedColumns: ["id"]
          },
        ]
      }
      seasons: {
        Row: {
          created_at: string
          end_date: string
          id: string
          label: string
          phase_id: string
          start_date: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          end_date: string
          id?: string
          label: string
          phase_id: string
          start_date: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          end_date?: string
          id?: string
          label?: string
          phase_id?: string
          start_date?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "seasons_phase_id_fkey"
            columns: ["phase_id"]
            isOneToOne: false
            referencedRelation: "strategy_phases"
            referencedColumns: ["id"]
          },
        ]
      }
      strategic_objectives: {
        Row: {
          code: string
          created_at: string
          description_ar: string | null
          id: string
          priority_id: string
          status: Database["public"]["Enums"]["record_status"]
          title_ar: string
          updated_at: string
        }
        Insert: {
          code: string
          created_at?: string
          description_ar?: string | null
          id?: string
          priority_id: string
          status?: Database["public"]["Enums"]["record_status"]
          title_ar: string
          updated_at?: string
        }
        Update: {
          code?: string
          created_at?: string
          description_ar?: string | null
          id?: string
          priority_id?: string
          status?: Database["public"]["Enums"]["record_status"]
          title_ar?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "strategic_objectives_priority_id_fkey"
            columns: ["priority_id"]
            isOneToOne: false
            referencedRelation: "priorities"
            referencedColumns: ["id"]
          },
        ]
      }
      strategic_paths: {
        Row: {
          code: string | null
          created_at: string
          description_ar: string | null
          id: string
          number: number
          strategy_id: string
          title_ar: string
          updated_at: string
        }
        Insert: {
          code?: string | null
          created_at?: string
          description_ar?: string | null
          id?: string
          number: number
          strategy_id: string
          title_ar: string
          updated_at?: string
        }
        Update: {
          code?: string | null
          created_at?: string
          description_ar?: string | null
          id?: string
          number?: number
          strategy_id?: string
          title_ar?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "strategic_paths_strategy_id_fkey"
            columns: ["strategy_id"]
            isOneToOne: false
            referencedRelation: "strategies"
            referencedColumns: ["id"]
          },
        ]
      }
      strategies: {
        Row: {
          code: string
          created_at: string
          end_year: number
          id: string
          start_year: number
          status: Database["public"]["Enums"]["record_status"]
          title_ar: string
          updated_at: string
          version: number
        }
        Insert: {
          code: string
          created_at?: string
          end_year: number
          id?: string
          start_year: number
          status?: Database["public"]["Enums"]["record_status"]
          title_ar: string
          updated_at?: string
          version?: number
        }
        Update: {
          code?: string
          created_at?: string
          end_year?: number
          id?: string
          start_year?: number
          status?: Database["public"]["Enums"]["record_status"]
          title_ar?: string
          updated_at?: string
          version?: number
        }
        Relationships: []
      }
      strategy_phases: {
        Row: {
          created_at: string
          end_year: number
          id: string
          label: string
          number: number
          start_year: number
          status: Database["public"]["Enums"]["record_status"]
          strategy_id: string
          updated_at: string
        }
        Insert: {
          created_at?: string
          end_year: number
          id?: string
          label: string
          number: number
          start_year: number
          status?: Database["public"]["Enums"]["record_status"]
          strategy_id: string
          updated_at?: string
        }
        Update: {
          created_at?: string
          end_year?: number
          id?: string
          label?: string
          number?: number
          start_year?: number
          status?: Database["public"]["Enums"]["record_status"]
          strategy_id?: string
          updated_at?: string
        }
        Relationships: [
          {
            foreignKeyName: "strategy_phases_strategy_id_fkey"
            columns: ["strategy_id"]
            isOneToOne: false
            referencedRelation: "strategies"
            referencedColumns: ["id"]
          },
        ]
      }
      user_roles: {
        Row: {
          created_at: string
          id: string
          org_unit_id: string | null
          role: Database["public"]["Enums"]["app_role"]
          user_id: string
        }
        Insert: {
          created_at?: string
          id?: string
          org_unit_id?: string | null
          role: Database["public"]["Enums"]["app_role"]
          user_id: string
        }
        Update: {
          created_at?: string
          id?: string
          org_unit_id?: string | null
          role?: Database["public"]["Enums"]["app_role"]
          user_id?: string
        }
        Relationships: [
          {
            foreignKeyName: "user_roles_org_unit_id_fkey"
            columns: ["org_unit_id"]
            isOneToOne: false
            referencedRelation: "org_units"
            referencedColumns: ["id"]
          },
        ]
      }
    }
    Views: {
      [_ in never]: never
    }
    Functions: {
      can_access_unit: { Args: { _unit_id: string }; Returns: boolean }
      can_manage_unit: { Args: { _unit_id: string }; Returns: boolean }
      has_role: {
        Args: {
          _role: Database["public"]["Enums"]["app_role"]
          _user_id: string
        }
        Returns: boolean
      }
      is_strategy_admin: { Args: never; Returns: boolean }
      is_super_admin: { Args: never; Returns: boolean }
      rebuild_org_unit_closure: { Args: never; Returns: undefined }
    }
    Enums: {
      app_role:
        | "PLATFORM_SUPER_ADMIN"
        | "STRATEGY_ADMIN"
        | "NATIONAL_MANAGER"
        | "REGIONAL_MANAGER"
        | "LOCAL_MANAGER"
        | "ACTIVITY_OWNER"
        | "REVIEWER"
        | "EVALUATOR"
        | "VIEWER"
      org_level: "national" | "regional" | "local"
      record_status: "draft" | "active" | "archived"
      validation_status: "draft" | "submitted" | "validated" | "rejected"
    }
    CompositeTypes: {
      [_ in never]: never
    }
  }
}

type DatabaseWithoutInternals = Omit<Database, "__InternalSupabase">

type DefaultSchema = DatabaseWithoutInternals[Extract<keyof Database, "public">]

export type Tables<
  DefaultSchemaTableNameOrOptions extends
    | keyof (DefaultSchema["Tables"] & DefaultSchema["Views"])
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
        DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? (DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"] &
      DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Views"])[TableName] extends {
      Row: infer R
    }
    ? R
    : never
  : DefaultSchemaTableNameOrOptions extends keyof (DefaultSchema["Tables"] &
        DefaultSchema["Views"])
    ? (DefaultSchema["Tables"] &
        DefaultSchema["Views"])[DefaultSchemaTableNameOrOptions] extends {
        Row: infer R
      }
      ? R
      : never
    : never

export type TablesInsert<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Insert: infer I
    }
    ? I
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Insert: infer I
      }
      ? I
      : never
    : never

export type TablesUpdate<
  DefaultSchemaTableNameOrOptions extends
    | keyof DefaultSchema["Tables"]
    | { schema: keyof DatabaseWithoutInternals },
  TableName extends (DefaultSchemaTableNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"]
    : never) = never,
> = DefaultSchemaTableNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaTableNameOrOptions["schema"]]["Tables"][TableName] extends {
      Update: infer U
    }
    ? U
    : never
  : DefaultSchemaTableNameOrOptions extends keyof DefaultSchema["Tables"]
    ? DefaultSchema["Tables"][DefaultSchemaTableNameOrOptions] extends {
        Update: infer U
      }
      ? U
      : never
    : never

export type Enums<
  DefaultSchemaEnumNameOrOptions extends
    | keyof DefaultSchema["Enums"]
    | { schema: keyof DatabaseWithoutInternals },
  EnumName extends (DefaultSchemaEnumNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"]
    : never) = never,
> = DefaultSchemaEnumNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[DefaultSchemaEnumNameOrOptions["schema"]]["Enums"][EnumName]
  : DefaultSchemaEnumNameOrOptions extends keyof DefaultSchema["Enums"]
    ? DefaultSchema["Enums"][DefaultSchemaEnumNameOrOptions]
    : never

export type CompositeTypes<
  PublicCompositeTypeNameOrOptions extends
    | keyof DefaultSchema["CompositeTypes"]
    | { schema: keyof DatabaseWithoutInternals },
  CompositeTypeName extends (PublicCompositeTypeNameOrOptions extends {
    schema: keyof DatabaseWithoutInternals
  }
    ? keyof DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"]
    : never) = never,
> = PublicCompositeTypeNameOrOptions extends {
  schema: keyof DatabaseWithoutInternals
}
  ? DatabaseWithoutInternals[PublicCompositeTypeNameOrOptions["schema"]]["CompositeTypes"][CompositeTypeName]
  : PublicCompositeTypeNameOrOptions extends keyof DefaultSchema["CompositeTypes"]
    ? DefaultSchema["CompositeTypes"][PublicCompositeTypeNameOrOptions]
    : never

export const Constants = {
  public: {
    Enums: {
      app_role: [
        "PLATFORM_SUPER_ADMIN",
        "STRATEGY_ADMIN",
        "NATIONAL_MANAGER",
        "REGIONAL_MANAGER",
        "LOCAL_MANAGER",
        "ACTIVITY_OWNER",
        "REVIEWER",
        "EVALUATOR",
        "VIEWER",
      ],
      org_level: ["national", "regional", "local"],
      record_status: ["draft", "active", "archived"],
      validation_status: ["draft", "submitted", "validated", "rejected"],
    },
  },
} as const
