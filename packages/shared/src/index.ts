export interface WorkflowNode {
  id: string;
  name: string;
  parameters: Record<string, any>;
  type: string;
  typeVersion: number;
  position: [number, number];
}
export interface Workflow {
  nodes: WorkflowNode[];
  connections: Record<string, any>;
}
